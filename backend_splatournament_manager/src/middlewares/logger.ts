import express from 'express';
import path from 'path';
import fs from 'fs';


const filePath = path.join(process.cwd(), 'request_logs.txt');
const router = express.Router();

router.use((req, res, next) => {
    const log = `\n[${new Date().toLocaleString()}] ${req.method} ${req.url}`;
    console.log(log);

    fs.appendFile(filePath, log, (err) => {
        if (err) console.error("Writing to log failed", err);
    });

    next();
});

export = router;
