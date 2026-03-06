import { User } from '../models/user';
import { Database } from 'sqlite3';
import * as argon2 from 'argon2';

export class UserService {
    private db: Database;

    constructor(db: Database) {
        this.db = db;
        this.db.run(`CREATE TABLE IF NOT EXISTS Users
                     (
                         id       INTEGER PRIMARY KEY AUTOINCREMENT,
                         username TEXT UNIQUE NOT NULL,
                         password TEXT NOT NULL
                     )`);
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


