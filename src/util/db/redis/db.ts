import config from '../../../config';

// eslint-disable-next-line @typescript-eslint/no-require-imports
const redis = config.tokenStoreType === 'redis' ? require('redis') : null;

let RedisClient: any = null;

if (config.tokenStoreType === 'redis') {
  RedisClient = redis.createClient(config.db.redisPort, config.db.redisHost, {
    password: config.db.redisPassword,
    db: config.db.redisDb,
  });
}

export default RedisClient;
