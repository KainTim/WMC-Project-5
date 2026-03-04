import express, {Request, Response} from 'express';
import bodyParser from 'body-parser';
import 'dotenv/config';

import {TournamentService} from './services/tournament-service';
import router from './middlewares/logger';


const tournamentService = new TournamentService();
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

app.listen(port, () => {
    console.log(`server started on port ${port}`);
});
