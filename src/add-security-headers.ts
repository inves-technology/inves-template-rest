import helmet from 'koa-helmet';
import Koa from 'koa';

export function addSecurityHeaders(app: Koa) {
  app.use(helmet());
  app.use(
    helmet.contentSecurityPolicy({
      directives: {
        defaultSrc: ["'self'"],
        baseUri: ["'self'"],
        fontSrc: ["'none'"],
        frameSrc: ["'none'"],
        mediaSrc: ["'none'"],
        imgSrc: ["'self'"],
        styleSrc: ["'self'"],
        connectSrc: ["'none'"],
        scriptSrc: ["'self'"],
        objectSrc: ["'none'"],
        childSrc: ["'none'"],
        formAction: ["'none'"],
        frameAncestors: ["'none'"],
      },
    }),
  );
  app.use(async (ctx, next) => {
    ctx.set('Permissions-Policy', 'geolocation=(), interest-cohort=()');
    ctx.set('Allow', 'GET');
    await next();
  });
}
