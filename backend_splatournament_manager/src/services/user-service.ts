import { User } from '../models/user';
import { Database } from 'sqlite3';
import * as argon2 from 'argon2';
import fs from "fs";
import path from "path";

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

    register(username: string, password: string): Promise<{ id: number; username: string }> {
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
                        resolve({ id: this.lastID, username });
                    }
                );
            } catch (err) {
                reject(err);
            }
        });
    }

    login(username: string, password: string): Promise<{ id: number; username: string }> {
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
                        resolve({ id: user.id, username: user.username });
                    } catch (e) {
                        reject(e);
                    }
                }
            );
        });
    }
}


