import { Request, Response, NextFunction } from 'express';
import * as jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || "key"

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).send({ error: 'Nicht autorisiert: Kein Token angegeben' });
    }
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as jwt.JwtPayload;
        // @ts-ignore
        req.user = decoded;
        console.log("User authenticated:", decoded.username);

        next();
    } catch (err) {
        return res.status(401).send({ error: 'Nicht autorisiert: Ungültiger Token' });
    }
};
