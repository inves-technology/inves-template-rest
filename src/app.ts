import { addSecurityHeaders } from './add-security-headers';
import { createLogger } from './create-logger';
import { getConfig } from './config';
import { home } from './home';
import dotenv from 'dotenv';
import Koa from 'koa';
import koaLogger from 'koa-logger';
import Router from '@koa/router';

const app = new Koa();
const router = new Router();

// security headers
addSecurityHeaders(app);

// config
dotenv.config();
app.context.config = getConfig();

// loggers
app.use(koaLogger());
app.context.logger = createLogger(app.context.config);

// routes
router.get('/', home);
app.use(router.routes()).use(router.allowedMethods());

export default app;
