import { Team, TournamentTeam, TeamMember } from '../models/team';
import { Database, RunResult } from 'sqlite3';
import fs from 'fs';
import path from 'path';

export class TeamService {
  private db: Database;
  private csvFilename = 'csv/teams.csv';

  constructor(db: Database) {
    this.db = db;
    this.db.serialize(() => {
      this.db.run(`CREATE TABLE IF NOT EXISTS Teams
                   (
                       id          INTEGER PRIMARY KEY AUTOINCREMENT,
                       name        TEXT    NOT NULL,
                       tag         TEXT    NOT NULL,
                       description TEXT,
                       createdAt   TEXT    NOT NULL DEFAULT (datetime('now'))
                   )`);

      this.db.run(`CREATE TABLE IF NOT EXISTS TournamentTeams
                   (
                       id           INTEGER PRIMARY KEY AUTOINCREMENT,
                       tournamentId INTEGER NOT NULL,
                       teamId       INTEGER NOT NULL,
                       registeredAt TEXT    NOT NULL DEFAULT (datetime('now')),
                       FOREIGN KEY (tournamentId) REFERENCES Tournaments (id) ON DELETE CASCADE,
                       FOREIGN KEY (teamId) REFERENCES Teams (id) ON DELETE CASCADE,
                       UNIQUE (tournamentId, teamId)
                   )`);

      this.db.run(`CREATE TABLE IF NOT EXISTS TeamMembers
                   (
                       id       INTEGER PRIMARY KEY AUTOINCREMENT,
                       teamId   INTEGER NOT NULL,
                       userId   INTEGER NOT NULL,
                       role     TEXT    NOT NULL DEFAULT 'member',
                       joinedAt TEXT    NOT NULL DEFAULT (datetime('now')),
                       FOREIGN KEY (teamId) REFERENCES Teams (id) ON DELETE CASCADE,
                       FOREIGN KEY (userId) REFERENCES Users (id) ON DELETE CASCADE,
                       UNIQUE (teamId, userId)
                   )`);

      this.seedDb();
    });
  }

  getAllTeams(): Promise<Team[]> {
    return new Promise<Team[]>((resolve, reject) => {
      this.db.all(
        `SELECT t.*, COUNT(tm.id) as memberCount 
         FROM Teams t 
         LEFT JOIN TeamMembers tm ON t.id = tm.teamId 
         GROUP BY t.id`,
        (err: Error | null, rows: Team[]) => {
          if (err) return reject(err);
          resolve(rows);
        }
      );
    });
  }

  getTeamById(id: number): Promise<Team | undefined> {
    return new Promise<Team | undefined>((resolve, reject) => {
      this.db.get(
        `SELECT * FROM Teams WHERE id = ?`,
        [id],
        (err: Error | null, row: Team | undefined) => {
          if (err) return reject(err);
          resolve(row);
        }
      );
    });
  }

  addTeam(team: Omit<Team, 'id' | 'createdAt'>): Promise<Team> {
    return new Promise<Team>((resolve, reject) => {
      const stmt = this.db.prepare(
        `INSERT INTO Teams (name, tag, description) VALUES (?, ?, ?)`
      );
      stmt.run(team.name, team.tag, team.description, function (this: RunResult, err: Error | null) {
        if (err) return reject(err);
        resolve({ id: (this as any).lastID, createdAt: new Date().toISOString(), ...team });
      });
      stmt.finalize();
    });
  }

  updateTeam(id: number, team: Partial<Omit<Team, 'id' | 'createdAt'>>): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.run(
        `UPDATE Teams SET name = COALESCE(?, name), tag = COALESCE(?, tag), description = COALESCE(?, description) WHERE id = ?`,
        [team.name ?? null, team.tag ?? null, team.description ?? null, id],
        (err: Error | null) => {
          if (err) return reject(err);
          resolve();
        }
      );
    });
  }

  deleteTeam(id: number): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.run(`DELETE FROM Teams WHERE id = ?`, [id], (err: Error | null) => {
        if (err) return reject(err);
        resolve();
      });
    });
  }

  getTeamsByTournamentId(tournamentId: number): Promise<Team[]> {
    return new Promise<Team[]>((resolve, reject) => {
      this.db.all(
        `SELECT t.*, tt.registeredAt
         FROM Teams t
                  INNER JOIN TournamentTeams tt ON t.id = tt.teamId
         WHERE tt.tournamentId = ?`,
        [tournamentId],
        (err: Error | null, rows: Team[]) => {
          if (err) return reject(err);
          resolve(rows);
        }
      );
    });
  }

  getTournamentsByTeamId(teamId: number): Promise<TournamentTeam[]> {
    return new Promise<TournamentTeam[]>((resolve, reject) => {
      this.db.all(
        `SELECT * FROM TournamentTeams WHERE teamId = ?`,
        [teamId],
        (err: Error | null, rows: TournamentTeam[]) => {
          if (err) return reject(err);
          resolve(rows);
        }
      );
    });
  }

  registerTeamForTournament(tournamentId: number, teamId: number): Promise<TournamentTeam> {
    return new Promise<TournamentTeam>((resolve, reject) => {
      const stmt = this.db.prepare(
        `INSERT INTO TournamentTeams (tournamentId, teamId) VALUES (?, ?)`
      );
      stmt.run(tournamentId, teamId, function (this: RunResult, err: Error | null) {
        if (err) return reject(err);
        resolve({
          id: (this as any).lastID,
          tournamentId,
          teamId,
          registeredAt: new Date().toISOString(),
        });
      });
      stmt.finalize();
    });
  }

  removeTeamFromTournament(tournamentId: number, teamId: number): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.run(
        `DELETE FROM TournamentTeams WHERE tournamentId = ? AND teamId = ?`,
        [tournamentId, teamId],
        (err: Error | null) => {
          if (err) return reject(err);
          resolve();
        }
      );
    });
  }

  addTeamMember(teamId: number, userId: number, role: 'owner' | 'member' = 'member'): Promise<TeamMember> {
    return new Promise<TeamMember>((resolve, reject) => {
      // First check if team already has 4 members
      this.db.get(
        `SELECT COUNT(*) as count FROM TeamMembers WHERE teamId = ?`,
        [teamId],
        (err: Error | null, row: any) => {
          if (err) return reject(err);
          if (row.count >= 4) {
            return reject(new Error('Team already has maximum of 4 members'));
          }
          
          const stmt = this.db.prepare(`INSERT INTO TeamMembers (teamId, userId, role) VALUES (?, ?, ?)`);
          stmt.run(teamId, userId, role, function (this: RunResult, err: Error | null) {
            if (err) return reject(err);
            resolve({
              id: (this as any).lastID,
              teamId,
              userId,
              role,
              joinedAt: new Date().toISOString(),
            });
          });
          stmt.finalize();
        }
      );
    });
  }

  removeTeamMember(teamId: number, userId: number): Promise<void> {
    return new Promise((resolve, reject) => {
      this.db.run(
        `DELETE FROM TeamMembers WHERE teamId = ? AND userId = ?`,
        [teamId, userId],
        (err: Error | null) => {
          if (err) return reject(err);
          resolve();
        }
      );
    });
  }

  getTeamsByUserId(userId: number): Promise<Team[]> {
    return new Promise<Team[]>((resolve, reject) => {
      this.db.all(
        `SELECT t.*, tm.role, tm.joinedAt FROM Teams t
         INNER JOIN TeamMembers tm ON t.id = tm.teamId
         WHERE tm.userId = ?`,
        [userId],
        (err: Error | null, rows: Team[]) => {
          if (err) return reject(err);
          resolve(rows);
        }
      );
    });
  }

  getTeamMembers(teamId: number): Promise<TeamMember[]> {
    return new Promise<TeamMember[]>((resolve, reject) => {
      this.db.all(
        `SELECT tm.*, u.username FROM TeamMembers tm
         INNER JOIN Users u ON tm.userId = u.id
         WHERE tm.teamId = ?`,
        [teamId],
        (err: Error | null, rows: TeamMember[]) => {
          if (err) return reject(err);
          resolve(rows);
        }
      );
    });
  }

  isUserInTeam(teamId: number, userId: number): Promise<boolean> {
    return new Promise<boolean>((resolve, reject) => {
      this.db.get(
        `SELECT COUNT(*) as count FROM TeamMembers WHERE teamId = ? AND userId = ?`,
        [teamId, userId],
        (err: Error | null, row: any) => {
          if (err) return reject(err);
          resolve(row.count > 0);
        }
      );
    });
  }

  private seedDb() {
    const csvPath = path.join(process.cwd(), "dist", this.csvFilename);
    if (fs.existsSync(csvPath)) {
      this.db.get(`SELECT COUNT(*) as count FROM Teams`, (err: Error | null, row: any) => {
        if (err) {
          console.error('Error checking Teams table:', err);
          return;
        }
        if (row.count === 0) {
          fs.readFile(csvPath, 'utf8', (err, data) => {
            if (err) {
              console.error('Error reading teams CSV:', err);
              return;
            }
            const lines = data.split('\n');
            lines.shift();
            const stmt = this.db.prepare(`INSERT INTO Teams (name, tag, description) VALUES (?, ?, ?)`);
            lines.forEach((line: string) => {
              const [name, tag, description] = line.split(',');
              if (name && tag) {
                stmt.run([name.trim(), tag.trim(), description?.trim() || '']);
              }
            });
            stmt.finalize();
            console.log('Teams seeded successfully');
          });
        }
      });
    }
  }
}

