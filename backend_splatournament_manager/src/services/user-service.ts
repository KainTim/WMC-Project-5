import { User } from '../models/user';
import { Database } from 'sqlite3';
import * as argon2 from 'argon2';
import * as jwt from 'jsonwebtoken';
import fs from "fs";
import path from "path";

const JWT_SECRET = process.env.JWT_SECRET || "key";

export class UserService {
    private csvFilename = 'csv/users.csv';
    private db: Database;

    constructor(db: Database) {
        this.db = db;
        this.db.serialize(() => {
            this.db.run(`CREATE TABLE IF NOT EXISTS Users
                     (
                         id       INTEGER PRIMARY KEY AUTOINCREMENT,
                         username TEXT UNIQUE NOT NULL,
                         password TEXT        NOT NULL
                     )`);
            this.seedDb();
        })
    }

    seedDb() {
        fs.readFile(path.join(process.cwd(), "dist", this.csvFilename), 'utf-8', async (_, data) => {
            const entries = data.split('\n');
            entries.shift();
            const lines = entries.filter(line => line.trim());
            const statement = this.db.prepare(`INSERT INTO Users
                                                   (username, password)
                                               VALUES (?, ?)`);
            for (const line of lines) {
                const parts = line.split(',');
                const username = parts[0].trim();
                const hash = await argon2.hash(parts[1].trim());
                statement.run(username, hash);
                console.log({ username, password: hash });
            }
            statement.finalize();
        });
    }

    register(username: string, password: string): Promise<{ id: number; username: string; token: string }> {
        return new Promise(async (resolve, reject) => {
            try {
                const hash = await argon2.hash(password);
                this.db.run(
                    'INSERT INTO Users (username, password) VALUES (?, ?)',
                    [username, hash],
                    function (err: Error | null) {
                        if (err) {
                            return reject(err);
                        }
                        const token = jwt.sign({ id: this.lastID, username }, JWT_SECRET, { expiresIn: '7d' });
                        resolve({ id: this.lastID, username, token });
                    }
                );
            } catch (err) {
                reject(err);
            }
        });
    }

    login(username: string, password: string): Promise<{ id: number; username: string; token: string }> {
        return new Promise((resolve, reject) => {
            this.db.get(
                'SELECT * FROM Users WHERE username = ?',
                [username],
                async (err: Error | null, user: User | undefined) => {
                    if (err) {
                        return reject(err);
                    }
                    if (!user) {
                        return reject(new Error('User not found'));
                    }
                    try {
                        const valid = await argon2.verify(user.password, password);
                        if (!valid) {
                            return reject(new Error('Invalid password'));
                        }
                        const token = jwt.sign({ id: user.id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });
                        resolve({ id: user.id, username: user.username, token });
                    } catch (e) {
                        reject(e);
                    }
                }
            );
        });
    }

    getUserByUsername(username: string): Promise<User | undefined> {
        return new Promise((resolve, reject) => {
            this.db.get(
                'SELECT id, username FROM Users WHERE username = ?',
                [username],
                (err: Error | null, user: User | undefined) => {
                    if (err) return reject(err);
                    resolve(user);
                }
            );
        });
    }
}
