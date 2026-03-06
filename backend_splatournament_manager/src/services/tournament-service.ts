import {Tournament} from '../models/tournament';
import fs from 'fs';
import path from 'path';
import {Database, RunResult} from "sqlite3";

export class TournamentService {
    private csvFilename = 'csv/tournaments.csv';
    private db: Database;

    constructor(db: Database) {
        this.db = db;
        this.db.serialize(() => {
            this.db.run(`CREATE TABLE IF NOT EXISTS Tournaments
                         (
                             id                INTEGER PRIMARY KEY AUTOINCREMENT,
                             name              TEXT,
                             description       TEXT,
                             maxTeamAmount     INTEGER,
                             currentTeamAmount INTEGER
                         )`);
        })
        this.seedDb();
    }

    getAllTournaments(): Promise<Tournament[]> {
        return new Promise<Tournament[]>((resolve, reject) => {
            this.db.all(`SELECT *
                         FROM Tournaments`, (err: RunResult, rows: Tournament[]) => {
                if (!err) {
                    resolve(rows);
                }
                reject(err);
            });
        });
    }

    getTournamentById(id: number): Promise<Tournament> {
        return new Promise<Tournament>((resolve, reject) => {
            this.db.get(`Select *
                         From Tournaments
                         WHERE id = ${id}`, (err: RunResult, tournament: Tournament) => {
                if (!err) {
                    resolve(tournament);
                }
                reject(err);
            });
        })
    }

    addTournament(tournament: Tournament): Promise<void> {
        return new Promise<void>((resolve, reject) => {
            const statement = this.db.prepare('Insert Into Tournaments (name, description, maxTeamAmount, currentTeamAmount) VALUES (?, ?, ?, ?)')
            statement.run(tournament.name, tournament.description, tournament.maxTeamAmount, tournament.currentTeamAmount);
            resolve();
        })
    }

    updateTournament(id: number, updatedTournament: Tournament): Promise<void> {
        return new Promise((resolve, reject) => {
            this.db.run(`Update Tournaments
                         Set name              = $name,
                             description       = $description,
                             maxTeamAmount     = $maxTeamAmount,
                             currentTeamAmount = $currentTeamAmount
                         where id = $id`, {
                $id: id,
                $description: updatedTournament.description,
                $maxTeamAmount: updatedTournament.maxTeamAmount,
                $currentTeamAmount: updatedTournament.currentTeamAmount,
            });
            resolve();
        })
    }

    deleteTournament(id: number): Promise<void> {
        return new Promise((resolve, reject) => {
            this.db.run('Delete From Tournaments where id = $id', {
                $id: id,
            });
            resolve();
        })
    }

    private seedDb() {
        fs.readFile(path.join(process.cwd(), "dist", this.csvFilename), 'utf-8', (_, data) => {
            const entries = data.split('\n');
            entries.shift();
            const statement = this.db.prepare(`INSERT INTO Tournaments
                                                   (name, description, maxTeamAmount, currentTeamAmount)
                                               VALUES (?, ?, ?, ?)`);
            entries.forEach(line => {
                if (line) {
                    const parts = line.split(',');
                    const tournament = {
                        id: 0,
                        name: parts[0].trim(),
                        description: parts[1].trim(),
                        maxTeamAmount: +parts[2],
                        currentTeamAmount: +parts[3]
                    } as Tournament;
                    statement.run(tournament.name, tournament.description, tournament.maxTeamAmount, tournament.currentTeamAmount);
                    console.log(tournament)
                }
            });
            statement.finalize();
        });
    }
}
