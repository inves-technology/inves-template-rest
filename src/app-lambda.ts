import serverless from 'serverless-http';
import app from './app';

const binaryFiles: string[] = []; // e.g   ['application/pdf', 'image/png', 'image/jpg', 'image/x-icon', 'image/vnd.microsoft.icon'];

export const handler = async (event: object, context: object) => {
  const handler = serverless(app, { binary: binaryFiles });
  const result = await handler(event, context);
  return result;
};
