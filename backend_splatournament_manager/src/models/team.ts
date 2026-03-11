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

export interface TeamMember {
  id: number;
  teamId: number;
  userId: number;
  role: 'owner' | 'member';
  joinedAt: string;
}

