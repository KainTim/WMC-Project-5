import express, {Request, Response} from 'express';
import bodyParser from 'body-parser';
import 'dotenv/config';

import {TournamentService} from './services/tournament-service';
import {UserService} from './services/user-service';
import {TeamService} from './services/team-service';
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
        return res.status(404).send({error: 'Tournament not found'});
    }
    res.send(tournament);
});

app.post('/tournaments', authMiddleware, async (req: Request, res: Response) => {
    try {
        await tournamentService.addTournament(req.body);
        res.status(201).send();
    } catch (err){
        console.log(err);
        res.status(400).send({error: 'Failed to create tournament'});
    }
});

app.put('/tournaments/:id', authMiddleware, async (req: Request, res: Response) => {
    try {
        await tournamentService.updateTournament(+req.params.id, req.body);
    } catch (err) {
        return res.status(400).send({error: 'Failed to update Tournament'});
    }
    res.status(200).send({message: 'Tournament updated successfully'});
});

app.delete('/tournaments/:id', authMiddleware, async (req: Request, res: Response) => {
    try {
        await tournamentService.deleteTournament(+req.params.id);
    } catch (err) {
        return res.status(400).send({error: 'Failed to delete Tournament'});
    }
    res.status(200).send({message: 'Tournament deleted successfully'});
});

app.get('/teams', async (req: Request, res: Response) => {
    const teams = await teamService.getAllTeams();
    res.send(teams);
});

app.get('/teams/:id', async (req: Request, res: Response) => {
    const team = await teamService.getTeamById(+req.params.id);
    if (!team) {
        return res.status(404).send({error: 'Team not found'});
    }
    res.send(team);
});

app.post('/teams', authMiddleware, async (req: Request, res: Response) => {
    const {name, tag, description} = req.body;
    if (!name || !tag) {
        return res.status(400).send({error: 'name and tag are required'});
    }
    try {
        const team = await teamService.addTeam({name, tag, description: description ?? ''});
        res.status(201).send(team);
    } catch (err) {
        console.log(err);
        res.status(400).send({error: 'Failed to create team'});
    }
});

app.put('/teams/:id', authMiddleware, async (req: Request, res: Response) => {
    try {
        await teamService.updateTeam(+req.params.id, req.body);
    } catch (err) {
        return res.status(400).send({error: 'Failed to update team'});
    }
    res.status(200).send({message: 'Team updated successfully'});
});

app.delete('/teams/:id', authMiddleware, async (req: Request, res: Response) => {
    try {
        await teamService.deleteTeam(+req.params.id);
    } catch (err) {
        return res.status(400).send({error: 'Failed to delete team'});
    }
    res.status(200).send({message: 'Team deleted successfully'});
});

app.get('/tournaments/:id/teams', async (req: Request, res: Response) => {
    const teams = await teamService.getTeamsByTournamentId(+req.params.id);
    res.send(teams);
});

app.post('/tournaments/:id/teams', authMiddleware, async (req: Request, res: Response) => {
    const {teamId} = req.body;
    if (!teamId) {
        return res.status(400).send({error: 'teamId is required'});
    }
    try {
        const entry = await teamService.registerTeamForTournament(+req.params.id, +teamId);
        res.status(201).send(entry);
    } catch (err: any) {
        if (err.message?.includes('UNIQUE constraint failed')) {
            return res.status(409).send({error: 'Team is already registered for this tournament'});
        }
        res.status(400).send({error: 'Failed to register team'});
    }
});

app.delete('/tournaments/:id/teams/:teamId', authMiddleware, async (req: Request, res: Response) => {
    try {
        await teamService.removeTeamFromTournament(+req.params.id, +req.params.teamId);
    } catch (err) {
        return res.status(400).send({error: 'Failed to remove team from tournament'});
    }
    res.status(200).send({message: 'Team removed from tournament'});
});

app.get('/teams/:id/tournaments', async (req: Request, res: Response) => {
    const entries = await teamService.getTournamentsByTeamId(+req.params.id);
    res.send(entries);
});

app.post('/register', async (req: Request, res: Response) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).send({ error: 'Username and password are required' });
    }
    try {
        const user = await userService.register(username, password);
        res.status(201).send(user);
    } catch (err: any) {
        if (err.message?.includes('UNIQUE constraint failed')) {
            return res.status(409).send({ error: 'Username already exists' });
        }
        res.status(500).send({ error: 'Registration failed' });
    }
});

app.post('/login', async (req: Request, res: Response) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).send({ error: 'Username and password are required' });
    }
    try {
        const user = await userService.login(username, password);
        res.status(200).send(user);
    } catch (err: any) {
        res.status(401).send({ error: err.message || 'Login failed' });
    }
});

app.listen(port, () => {
    console.log(`server started on port ${port}`);
});
