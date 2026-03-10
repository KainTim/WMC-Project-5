import { Tournament } from '../models/tournament';
import { Team } from '../models/team';
import fs from 'fs';
import path from 'path';
import { Database, RunResult } from "sqlite3";

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
                             registrationStartDate TEXT,
                             registrationEndDate TEXT
                         )`);
        })
        this.seedDb();
    }

    getAllTournaments(): Promise<Tournament[]> {
        return new Promise<Tournament[]>((resolve, reject) => {
            this.db.all(
                `SELECT t.*, tm.id as teamId, tm.name as teamName, tm.tag as teamTag,
                        tm.description as teamDescription, tm.createdAt as teamCreatedAt
                 FROM Tournaments t
                 LEFT JOIN TournamentTeams tt ON t.id = tt.tournamentId
                 LEFT JOIN Teams tm ON tt.teamId = tm.id`,
                (err: Error | null, rows: any[]) => {
                    if (err) return reject(err);
                    const tournamentsMap = new Map<number, Tournament>();
                    for (const row of rows) {
                        if (!tournamentsMap.has(row.id)) {
                            tournamentsMap.set(row.id, {
                                id: row.id,
                                name: row.name,
                                description: row.description,
                                maxTeamAmount: row.maxTeamAmount,
                                currentTeamAmount: 0,
                                registrationStartDate: row.registrationStartDate,
                                registrationEndDate: row.registrationEndDate,
                                teams: [],
                            });
                        }
                        if (row.teamId) {
                            tournamentsMap.get(row.id)!.teams!.push({
                                id: row.teamId,
                                name: row.teamName,
                                tag: row.teamTag,
                                description: row.teamDescription,
                                createdAt: row.teamCreatedAt,
                            } as Team);
                            tournamentsMap.get(row.id)!.currentTeamAmount++;
                        }
                    }
                    resolve(Array.from(tournamentsMap.values()));
                }
            );
        });
    }

    getTournamentById(id: number): Promise<Tournament | undefined> {
        return new Promise<Tournament | undefined>((resolve, reject) => {
            this.db.all(
                `SELECT t.*, tm.id as teamId, tm.name as teamName, tm.tag as teamTag,
                        tm.description as teamDescription, tm.createdAt as teamCreatedAt
                 FROM Tournaments t
                 LEFT JOIN TournamentTeams tt ON t.id = tt.tournamentId
                 LEFT JOIN Teams tm ON tt.teamId = tm.id
                 WHERE t.id = ?`,
                [id],
                (err: Error | null, rows: any[]) => {
                    if (err) return reject(err);
                    if (!rows || rows.length === 0) return resolve(undefined);
                    const first = rows[0];
                    const tournament: Tournament = {
                        id: first.id,
                        name: first.name,
                        description: first.description,
                        maxTeamAmount: first.maxTeamAmount,
                        currentTeamAmount: first.currentTeamAmount,
                        registrationStartDate: first.registrationStartDate,
                        registrationEndDate: first.registrationEndDate,
                        teams: [],
                    };
                    for (const row of rows) {
                        if (row.teamId) {
                            tournament.teams!.push({
                                id: row.teamId,
                                name: row.teamName,
                                tag: row.teamTag,
                                description: row.teamDescription,
                                createdAt: row.teamCreatedAt,
                            } as Team);
                            tournament.currentTeamAmount++;
                        }
                    }
                    resolve(tournament);
                }
            );
        });
    }

    addTournament(tournament: Tournament): Promise<void> {
        return new Promise<void>((resolve, reject) => {
            const statement = this.db.prepare('Insert Into Tournaments (name, description, maxTeamAmount, registrationStartDate, registrationEndDate) VALUES (?, ?, ?, ?, ?)')
            statement.run(tournament.name, tournament.description, tournament.maxTeamAmount, tournament.registrationStartDate, tournament.registrationEndDate);
            resolve();
        })
    }

    updateTournament(id: number, updatedTournament: Tournament): Promise<void> {
        return new Promise((resolve, reject) => {
            this.db.run(`Update Tournaments
                         Set name              = $name,
                             description       = $description,
                             maxTeamAmount     = $maxTeamAmount,
                             registrationStartDate = $registrationStartDate,
                             registrationEndDate = $registrationEndDate
                         where id = $id`, {
                $id: id,
                $name: updatedTournament.name,
                $description: updatedTournament.description,
                $maxTeamAmount: updatedTournament.maxTeamAmount,
                $registrationStartDate: updatedTournament.registrationStartDate,
                $registrationEndDate: updatedTournament.registrationEndDate,
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
                                                   (name, description, maxTeamAmount, registrationStartDate, registrationEndDate)
                                               VALUES (?, ?, ?, ?, ?)`);
            entries.forEach(line => {
                if (line) {
                    const parts = line.split(',');
                    const tournament = {
                        id: 0,
                        name: parts[0].trim(),
                        description: parts[1].trim(),
                        maxTeamAmount: +parts[2],
                        currentTeamAmount: 0,
                        registrationStartDate: parts[4].trim(),
                        registrationEndDate: parts[5].trim()
                    } as Tournament;
                    statement.run(tournament.name, tournament.description, tournament.maxTeamAmount, tournament.registrationStartDate, tournament.registrationEndDate);
                    console.log(tournament)
                }
            });
            statement.finalize();
        });
    }
}
