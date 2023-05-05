import winston from 'winston';
import { Context as KoaContext } from 'koa';
import { Config } from './config';

export interface Context extends KoaContext {
  logger: winston.Logger;
  config: Config;
}
