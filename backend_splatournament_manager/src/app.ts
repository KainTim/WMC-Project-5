import express, {Request, Response} from 'express';
import bodyParser from 'body-parser';
import 'dotenv/config';

import {TournamentService} from './services/tournament-service';
import {UserService} from './services/user-service';
import router from './middlewares/logger';
import {Database} from 'sqlite3';
import fs from "fs";


const dbFilename = 'tournaments.sqlite';

if (fs.existsSync(dbFilename)){
    fs.unlinkSync(dbFilename);
}
const db = new Database(dbFilename);
const tournamentService = new TournamentService(db);
const userService = new UserService(db);
const port = process.env.PORT || 3000;
const app = express();

app.use(bodyParser.json());
app.use(router);

app.get('/tournaments', async (req: Request, res: Response) => {
    console.log(req.params)
    if (!req.params.id) {
        const tournaments = await tournamentService.getAllTournaments();
        console.log(tournaments)
        return res.send(tournaments);
    }
    const tournament = await tournamentService.getTournamentById(+req.params.id);
    if (!tournament) {
        return res.status(404).send({error: 'Tournament not found'});
    }
    res.send(tournament);
});

app.post('/tournaments', async (req: Request, res: Response) => {
    console.log("post");
    
    try {
        await tournamentService.addTournament(req.body);
        res.status(200).send();
    }catch (err){
        console.log(err);
        res.status(404).send();
    }
});

app.put('/tournaments', async (req: Request, res: Response) => {
    if (!req.query.id) {
        return res.status(400).send({error: 'Missing id parameter'});
    }
    try {
        const success = await tournamentService.updateTournament(+req.query.id!, req.body);
    } catch (err) {
        return res.status(400).send({error: 'Failed to update Tournament'});
    }
    res.status(200).send({message: 'Tournament updated successfully'});
});

app.delete('/tournaments', async (req: Request, res: Response) => {
    if (!req.query.id) {
        return res.status(400).send({error: 'Missing id parameter'});
    }
    try {
        const success = await tournamentService.deleteTournament(+req.query.id!);
    } catch (err) {
        return res.status(400).send({error: 'Failed to delete Tournament'});
    }
    res.status(200).send({message: 'Tournament deleted successfully'});
});

// Auth routes
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
