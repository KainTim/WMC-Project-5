export interface Match {
  id: number;
  tournamentId: number;
  round: number;
  matchNumber: number;
  team1Id: number | null;
  team2Id: number | null;
  winnerId: number | null;
}
