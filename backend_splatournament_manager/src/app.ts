import express, {Request, Response} from 'express';
import bodyParser from 'body-parser';
import 'dotenv/config';

import {TournamentService} from './services/tournament-service';
import {UserService} from './services/user-service';
import {TeamService} from './services/team-service';
import {MatchService} from './services/match-service';
import {authMiddleware} from './middlewares/auth-middleware';
import loggingMiddleware from './middlewares/logger';
import {Database} from 'sqlite3';
import fs from "fs";
import { log } from 'console';


const dbFilename = 'tournaments.sqlite';

if (fs.existsSync(dbFilename)){
    fs.unlinkSync(dbFilename);
}
const db = new Database(dbFilename);
const tournamentService = new TournamentService(db);
const userService = new UserService(db);
const teamService = new TeamService(db);
const matchService = new MatchService(db);
const port = process.env.PORT || 3000;
const app = express();

app.use(bodyParser.json());
app.use(loggingMiddleware);

app.get('/tournaments', async (req: Request, res: Response) => {
    const tournaments = await tournamentService.getAllTournaments();
    return res.send(tournaments);
});

app.get('/tournaments/:id', async (req: Request, res: Response) => {
    const tournament = await tournamentService.getTournamentById(+req.params.id);
    if (!tournament) {
        return res.status(404).send({error: 'Turnier nicht gefunden'});
    }
    res.send(tournament);
});

app.post('/tournaments', authMiddleware, async (req: Request, res: Response) => {
    try {
        await tournamentService.addTournament(req.body);
        res.status(201).send();
    } catch (err){
        console.log(err);
        res.status(400).send({error: 'Turnier konnte nicht erstellt werden'});
    }
});

app.put('/tournaments/:id', authMiddleware, async (req: Request, res: Response) => {
    try {
        await tournamentService.updateTournament(+req.params.id, req.body);
    } catch (err) {
        return res.status(400).send({error: 'Turnier konnte nicht aktualisiert werden'});
    }
    res.status(200).send({message: 'Turnier erfolgreich aktualisiert'});
});

app.delete('/tournaments/:id', authMiddleware, async (req: Request, res: Response) => {
    try {
        await tournamentService.deleteTournament(+req.params.id);
    } catch (err) {
        return res.status(400).send({error: 'Turnier konnte nicht gelöscht werden'});
    }
    res.status(200).send({message: 'Turnier erfolgreich gelöscht'});
});

app.post('/tournaments/:id/bracket', authMiddleware, async (req: Request, res: Response) => {
    try {
        const tournamentId = +req.params.id;
        const teams = await teamService.getTeamsByTournamentId(tournamentId);
        const teamIds = teams.map(team => team.id);
        const tournament = await tournamentService.getTournamentById(tournamentId);
        if (!tournament) {
            return res.status(404).send({error: 'Turnier nicht gefunden'});
        }

        if (teamIds.length < 2) {
            return res.status(400).send({error: 'Mindestens 2 Teams sind erforderlich, um den Turnierbaum zu initialisieren'});
        }

        if (teamIds.length < tournament.maxTeamAmount) {
            return res.status(400).send({error: `Es müssen alle ${tournament.maxTeamAmount} Teams angemeldet sein, um den Turnierbaum zu initialisieren`});
        }

        await matchService.initializeBracket(tournamentId, teamIds);
        res.status(201).send({message: 'Turnierbaum erfolgreich initialisiert'});
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Turnierbaum konnte nicht initialisiert werden'});
    }
});

app.get('/tournaments/:id/matches', async (req: Request, res: Response) => {
    try {
        const matches = await matchService.getMatchesByTournament(+req.params.id);
        res.send(matches);
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Matches konnten nicht geladen werden'});
    }
});

app.put('/matches/:id/winner', authMiddleware, async (req: Request, res: Response) => {
    try {
        const {winnerId} = req.body;
        if (!winnerId) {
            return res.status(400).send({error: 'winnerId ist erforderlich'});
        }
        await matchService.setMatchWinner(+req.params.id, +winnerId);
        res.status(200).send({message: 'Sieger erfolgreich festgelegt'});
    } catch (err: any) {
        console.log(err);
        res.status(400).send({error: err.message || 'Sieger konnte nicht festgelegt werden'});
    }
});

app.delete('/matches/:id/winner', authMiddleware, async (req: Request, res: Response) => {
    try {
        await matchService.resetMatch(+req.params.id);
        res.status(200).send({message: 'Match erfolgreich zurückgesetzt'});
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Match konnte nicht zurückgesetzt werden'});
    }
});

app.get('/teams', async (req: Request, res: Response) => {
    const teams = await teamService.getAllTeams();
    res.send(teams);
});

app.get('/teams/:id', async (req: Request, res: Response) => {
    const team = await teamService.getTeamById(+req.params.id);
    if (!team) {
        return res.status(404).send({error: 'Team nicht gefunden'});
    }
    res.send(team);
});

app.post('/teams', authMiddleware, async (req: Request, res: Response) => {
    const {name, tag, description} = req.body;
    if (!name || !tag) {
        return res.status(400).send({error: 'Name und Kürzel sind erforderlich'});
    }
    if (tag.length > 3) {
        return res.status(400).send({error: 'Das Kürzel darf höchstens 3 Zeichen lang sein'});
    }
    try {
        const team = await teamService.addTeam({name, tag, description: description ?? ''});
        // @ts-ignore
        const userId = req.user.id;
        await teamService.addTeamMember(team.id, userId, 'owner');
        res.status(201).send(team);
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Team konnte nicht erstellt werden'});
    }
});

app.put('/teams/:id', authMiddleware, async (req: Request, res: Response) => {
    const {tag} = req.body;
    if (tag && tag.length > 3) {
        return res.status(400).send({error: 'Das Kürzel darf höchstens 3 Zeichen lang sein'});
    }
    try {
        await teamService.updateTeam(+req.params.id, req.body);
    } catch (err) {
        return res.status(400).send({error: 'Team konnte nicht aktualisiert werden'});
    }
    res.status(200).send({message: 'Team erfolgreich aktualisiert'});
});

app.delete('/teams/:id', authMiddleware, async (req: Request, res: Response) => {
    try {
        await teamService.deleteTeam(+req.params.id);
    } catch (err) {
        return res.status(400).send({error: 'Team konnte nicht gelöscht werden'});
    }
    res.status(200).send({message: 'Team erfolgreich gelöscht'});
});

app.get('/tournaments/:id/teams', async (req: Request, res: Response) => {
    const teams = await teamService.getTeamsByTournamentId(+req.params.id);
    res.send(teams);
});

app.post('/tournaments/:id/teams', authMiddleware, async (req: Request, res: Response) => {
    const {teamId} = req.body;
    if (!teamId) {
        return res.status(400).send({error: 'teamId ist erforderlich'});
    }
    try {
        const entry = await teamService.registerTeamForTournament(+req.params.id, +teamId);
        res.status(201).send(entry);
    } catch (err: any) {
        if (err.message?.includes('UNIQUE constraint failed')) {
            return res.status(409).send({error: 'Das Team ist bereits für dieses Turnier angemeldet'});
        }
        res.status(400).send({error: 'Team konnte nicht für das Turnier angemeldet werden'});
    }
});

app.delete('/tournaments/:id/teams/:teamId', authMiddleware, async (req: Request, res: Response) => {
    try {
        await teamService.removeTeamFromTournament(+req.params.id, +req.params.teamId);
    } catch (err) {
        return res.status(400).send({error: 'Team konnte nicht aus dem Turnier entfernt werden'});
    }
    res.status(200).send({message: 'Team aus dem Turnier entfernt'});
});

app.get('/teams/:id/tournaments', async (req: Request, res: Response) => {
    const entries = await teamService.getTournamentsByTeamId(+req.params.id);
    res.send(entries);
});

app.get('/users/me/teams', authMiddleware, async (req: Request, res: Response) => {
    try {
        // @ts-ignore
        const userId = req.user.id;
        const teams = await teamService.getTeamsByUserId(userId);
        res.send(teams);
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Eigene Teams konnten nicht geladen werden'});
    }
});

app.post('/teams/:id/members', authMiddleware, async (req: Request, res: Response) => {
    try {
        // @ts-ignore
        const userId = req.user.id;
        const teamId = +req.params.id;
        
        const isInTeam = await teamService.isUserInTeam(teamId, userId);
        if (isInTeam) {
            return res.status(409).send({error: 'Du bist bereits Mitglied dieses Teams'});
        }
        
        const member = await teamService.addTeamMember(teamId, userId, 'member');
        res.status(201).send(member);
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Beitritt zum Team fehlgeschlagen'});
    }
});

app.delete('/teams/:id/members/me', authMiddleware, async (req: Request, res: Response) => {
    try {
        // @ts-ignore
        const userId = req.user.id;
        const teamId = +req.params.id;
        await teamService.removeTeamMember(teamId, userId);
        res.status(200).send({message: 'Team erfolgreich verlassen'});
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Team konnte nicht verlassen werden'});
    }
});

app.get('/teams/:id/members', async (req: Request, res: Response) => {
    try {
        const members = await teamService.getTeamMembers(+req.params.id);
        res.send(members);
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Teammitglieder konnten nicht geladen werden'});
    }
});

app.post('/register', async (req: Request, res: Response) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).send({ error: 'Benutzername und Passwort sind erforderlich' });
    }
    try {
        const user = await userService.register(username, password);
        res.status(201).send(user);
    } catch (err: any) {
        if (err.message?.includes('UNIQUE constraint failed')) {
            return res.status(409).send({ error: 'Benutzername existiert bereits' });
        }
        res.status(500).send({ error: 'Registrierung fehlgeschlagen' });
    }
});

app.post('/login', async (req: Request, res: Response) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).send({ error: 'Benutzername und Passwort sind erforderlich' });
    }
    try {
        const user = await userService.login(username, password);
        res.status(200).send(user);
    } catch (err: any) {
        res.status(401).send({ error: err.message || 'Anmeldung fehlgeschlagen' });
    }
});

app.listen(port, () => {
    console.log(`server started on port ${port}`);
});
