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

app.get('/tournaments/available', async (req: Request, res: Response) => {
    console.log(req.params)
    if (!req.params.id) {
        const tournaments = await tournamentService.getAllTournaments();
        console.log(tournaments)
        return res.send(tournaments);
    }
    const tournament = await tournamentService.getBookById(+req.params.id);
    if (!tournament) {
        return res.status(404).send({error: 'Book not found'});
    }
    res.send(tournament);
});

app.post('/books', async (req: Request, res: Response) => {
    console.log("post");
    
    try {
        await tournamentService.addBook(req.body);
        res.status(200).send();
    }catch (err){
        console.log(err);
        res.status(404).send();
    }
});

app.put('/books', async (req: Request, res: Response) => {
    if (!req.query.id) {
        return res.status(400).send({error: 'Missing id parameter'});
    }
    try {
        const success = await tournamentService.updateBook(+req.query.id!, req.body);
    } catch (err) {
        return res.status(400).send({error: 'Failed to update book'});
    }
    res.status(200).send({message: 'Book updated successfully'});
});

app.delete('/books', async (req: Request, res: Response) => {
    if (!req.query.id) {
        return res.status(400).send({error: 'Missing id parameter'});
    }
    try {
        const success = await tournamentService.deleteBook(+req.query.id!);
    } catch (err) {
        return res.status(400).send({error: 'Failed to delete book'});
    }
    res.status(200).send({message: 'Book deleted successfully'});
});

app.listen(port, () => {
    console.log(`server started on port ${port}`);
});
