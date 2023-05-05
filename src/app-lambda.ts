import serverless from 'serverless-http';
import app from './app';

const binaryFiles: string[] = []; // e.g   ['application/pdf', 'image/png', 'image/jpg', 'image/x-icon', 'image/vnd.microsoft.icon'];

// Ignoring Object rule for this, since serverless handler requires Object type
// eslint-disable-next-line @typescript-eslint/ban-types
module.exports.handler = async (event: Object, context: Object) => {
  const handler = serverless(app, { binary: binaryFiles });
  const result = await handler(event, context);
  return result;
};
