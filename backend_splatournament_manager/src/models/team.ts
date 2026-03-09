export interface Team {
  id: number;
  name: string;
  tag: string;
  description: string;
  createdAt: string;
}

export interface TournamentTeam {
  id: number;
  tournamentId: number;
  teamId: number;
  registeredAt: string;
}

