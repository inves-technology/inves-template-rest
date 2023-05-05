import { Config } from './config';
import { Context } from './context';

export function helloWorld(context: Context, name: string): string {
  try {
    context.logger.info(`helloWorldFunction`);
    const agent = context.get('User-Agent');
    const hello = sayHello(context.config, name, agent);
    return hello;
  } catch (error) {
    // Simple example to show logging errors with full stack. Note: error has to be passed to the logger
    context.logger.error('Do you even stack?', error);
    throw error;
  }
}

export function sayHello(config: Config, name: string, agent: string): string {
  return `Hello World! Project=${config.project} Stage=${config.stage} Agent=${agent} name=${name}`;
}
