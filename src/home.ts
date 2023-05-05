import { Context } from './context';
import { helloWorld } from './hello-world';

export async function home(ctx: Context): Promise<void> {
  ctx.logger.info('/home');
  ctx.body = helloWorld(ctx, 'Nobody');
}
