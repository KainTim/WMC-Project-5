import { Match } from '../models/match';
import { Database } from 'sqlite3';

export class MatchService {
    private db: Database;

    constructor(db: Database) {
        this.db = db;
        this.db.serialize(() => {
            this.db.run(`CREATE TABLE IF NOT EXISTS Matches
                         (
                             id           INTEGER PRIMARY KEY AUTOINCREMENT,
                             tournamentId INTEGER NOT NULL,
                             round        INTEGER NOT NULL,
                             matchNumber  INTEGER NOT NULL,
                             team1Id      INTEGER,
                             team2Id      INTEGER,
                             winnerId     INTEGER,
                             FOREIGN KEY (tournamentId) REFERENCES Tournaments(id) ON DELETE CASCADE,
                             FOREIGN KEY (team1Id) REFERENCES Teams(id) ON DELETE SET NULL,
                             FOREIGN KEY (team2Id) REFERENCES Teams(id) ON DELETE SET NULL,
                             FOREIGN KEY (winnerId) REFERENCES Teams(id) ON DELETE SET NULL
                         )`);
        });
    }

    /**
     * Initialize bracket for a tournament based on registered teams
     */
    initializeBracket(tournamentId: number, teamIds: number[]): Promise<void> {
        return new Promise((resolve, reject) => {
            // Determine bracket size (2, 4, or 8)
            const teamCount = teamIds.length;
            let bracketSize: number;
            if (teamCount <= 2) bracketSize = 2;
            else if (teamCount <= 4) bracketSize = 4;
            else bracketSize = 8;

            // Calculate number of rounds
            let roundCount: number;
            if (bracketSize === 2) roundCount = 1;
            else if (bracketSize === 4) roundCount = 2;
            else roundCount = 3;

            // First, check if matches already exist for this tournament
            this.db.get(
                'SELECT COUNT(*) as count FROM Matches WHERE tournamentId = ?',
                [tournamentId],
                (err, row: any) => {
                    if (err) return reject(err);
                    if (row.count > 0) {
                        // Matches already initialized
                        return resolve();
                    }

                    // Create first round matches
                    const statement = this.db.prepare(
                        'INSERT INTO Matches (tournamentId, round, matchNumber, team1Id, team2Id, winnerId) VALUES (?, ?, ?, ?, ?, ?)'
                    );

                    const firstRoundMatches = bracketSize / 2;
                    for (let i = 0; i < firstRoundMatches; i++) {
                        const team1Id = i * 2 < teamIds.length ? teamIds[i * 2] : null;
                        const team2Id = i * 2 + 1 < teamIds.length ? teamIds[i * 2 + 1] : null;
                        statement.run(tournamentId, 0, i, team1Id, team2Id, null);
                    }

                    // Create placeholder matches for subsequent rounds
                    for (let round = 1; round < roundCount; round++) {
                        const matchesInRound = bracketSize / Math.pow(2, round + 1);
                        for (let i = 0; i < matchesInRound; i++) {
                            statement.run(tournamentId, round, i, null, null, null);
                        }
                    }

                    // Create winner slot (final round)
                    statement.run(tournamentId, roundCount, 0, null, null, null, (err: Error | null) => {
                        if (err) return reject(err);
                        statement.finalize();
                        resolve();
                    });
                }
            );
        });
    }

    /**
     * Get all matches for a tournament
     */
    getMatchesByTournament(tournamentId: number): Promise<Match[]> {
        return new Promise((resolve, reject) => {
            this.db.all(
                'SELECT * FROM Matches WHERE tournamentId = ? ORDER BY round, matchNumber',
                [tournamentId],
                (err: Error | null, rows: any[]) => {
                    if (err) return reject(err);
                    const matches: Match[] = rows.map(row => ({
                        id: row.id,
                        tournamentId: row.tournamentId,
                        round: row.round,
                        matchNumber: row.matchNumber,
                        team1Id: row.team1Id,
                        team2Id: row.team2Id,
                        winnerId: row.winnerId,
                    }));
                    resolve(matches);
                }
            );
        });
    }

    /**
     * Set the winner of a match and progress them to the next round
     */
    setMatchWinner(matchId: number, winnerId: number): Promise<void> {
        return new Promise((resolve, reject) => {
            // First, get the match details
            this.db.get(
                'SELECT * FROM Matches WHERE id = ?',
                [matchId],
                (err, match: any) => {
                    if (err) return reject(err);
                    if (!match) return reject(new Error('Match not found'));

                    // Validate that the winnerId is one of the participants
                    if (match.team1Id !== winnerId && match.team2Id !== winnerId) {
                        return reject(new Error('Winner must be one of the match participants'));
                    }

                    // Update the match with winner
                    this.db.run(
                        'UPDATE Matches SET winnerId = ? WHERE id = ?',
                        [winnerId, matchId],
                        (err) => {
                            if (err) return reject(err);

                            // Progress winner to next round
                            const nextRound = match.round + 1;
                            const nextMatchNumber = Math.floor(match.matchNumber / 2);

                            // Find the next match
                            this.db.get(
                                'SELECT * FROM Matches WHERE tournamentId = ? AND round = ? AND matchNumber = ?',
                                [match.tournamentId, nextRound, nextMatchNumber],
                                (err, nextMatch: any) => {
                                    if (err) return reject(err);
                                    if (!nextMatch) {
                                        // This was the final match, no next round
                                        return resolve();
                                    }

                                    // Determine if winner goes to team1 or team2 slot
                                    const isEvenMatch = match.matchNumber % 2 === 0;
                                    const field = isEvenMatch ? 'team1Id' : 'team2Id';

                                    // Update next match with winner
                                    this.db.run(
                                        `UPDATE Matches SET ${field} = ? WHERE id = ?`,
                                        [winnerId, nextMatch.id],
                                        (err) => {
                                            if (err) return reject(err);
                                            resolve();
                                        }
                                    );
                                }
                            );
                        }
                    );
                }
            );
        });
    }

    /**
     * Reset a match (clear winner and remove from subsequent rounds)
     */
    resetMatch(matchId: number): Promise<void> {
        return new Promise((resolve, reject) => {
            // Get match details
            this.db.get(
                'SELECT * FROM Matches WHERE id = ?',
                [matchId],
                (err, match: any) => {
                    if (err) return reject(err);
                    if (!match) return reject(new Error('Match not found'));

                    const previousWinnerId = match.winnerId;

                    // Clear the winner
                    this.db.run(
                        'UPDATE Matches SET winnerId = NULL WHERE id = ?',
                        [matchId],
                        (err) => {
                            if (err) return reject(err);

                            if (!previousWinnerId) {
                                return resolve();
                            }

                            // Remove winner from next round
                            const nextRound = match.round + 1;
                            const nextMatchNumber = Math.floor(match.matchNumber / 2);
                            const isEvenMatch = match.matchNumber % 2 === 0;
                            const field = isEvenMatch ? 'team1Id' : 'team2Id';

                            this.db.run(
                                `UPDATE Matches SET ${field} = NULL WHERE tournamentId = ? AND round = ? AND matchNumber = ?`,
                                [match.tournamentId, nextRound, nextMatchNumber],
                                (err) => {
                                    if (err) return reject(err);
                                    resolve();
                                }
                            );
                        }
                    );
                }
            );
        });
    }
}
