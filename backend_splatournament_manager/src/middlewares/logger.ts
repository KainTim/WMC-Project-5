import express from 'express';
import path from 'path';
import fs from 'fs';


const filePath = path.join(process.cwd(), 'request_logs.txt');
const router = express.Router();

router.use((req, res, next) => {
    const log = `[${new Date().toLocaleString()}] ${req.method} ${req.url}\n`;
    console.log(log);

    fs.appendFile(filePath, log, (err) => {
        if (err) console.error("Request Failed", err);
    });

    next();
});

export = router;
