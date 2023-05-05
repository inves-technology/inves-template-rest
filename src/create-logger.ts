import winston from 'winston';
import { Config } from './config';

export function createLogger(config: Config) {
  const customFormat = winston.format.printf((logInfo): string => {
    return `[${logInfo.level}]\t|${logInfo.ms}\t|${logInfo.message}` + (logInfo.stack ? `\n\Stack:\n${logInfo.stack}` : '');
  });
  const logger = winston.createLogger({
    level: 'info',
    defaultMeta: { service: config.project, stage: config.stage },
    transports: [
      new winston.transports.Console({
        level: 'info',
        format: winston.format.combine(
          winston.format.timestamp(),
          winston.format.colorize(),
          winston.format.ms(),
          winston.format.errors({ stack: true }),
          customFormat,
        ),
        handleExceptions: true,
      }),
    ],
  });
  return logger;
}
