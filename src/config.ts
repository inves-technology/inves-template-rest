export type Config = {
  stage: string;
  project: string;
};

export function getConfig() {
  const config: Config = {
    stage: readEnv('STAGE'),
    project: readEnv('PROJECT'),
  };
  return config;
}

function readEnv(name: string) {
  const env = process.env[name];
  if (!env) throw new Error(`Invalid config. Failed to read ${name} from env`);
  return env;
}
