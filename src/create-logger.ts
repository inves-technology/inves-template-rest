import winston from 'winston';
import { Config } from './config';

const customFormat = winston.format.printf((logInfo: winston.Logform.TransformableInfo): string => {
  const { level, ms, message, stack } = logInfo;
  const formattedMessage = `[${level}]\t|${String(ms)}\t|${String(message)}`;
  const formattedStack = stack ? `\nStack:\n${JSON.stringify(stack, null, 2)}` : '';

  return `${formattedMessage}${formattedStack}`;
});

export function createLogger(config: Config) {
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
