import { Context } from './context';
import { helloWorld } from './hello-world';

export function home(ctx: Context) {
  ctx.logger.info('/home');
  ctx.body = helloWorld(ctx, 'Nobody');
}
