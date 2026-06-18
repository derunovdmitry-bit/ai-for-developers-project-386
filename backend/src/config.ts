export interface BackendConfig {
  adminPassword: string
  host: string
  port: number
}

export function readConfig(env: NodeJS.ProcessEnv = process.env): BackendConfig {
  const adminPassword = env.ADMIN_PASSWORD

  if (!adminPassword) {
    throw new Error('ADMIN_PASSWORD is required to start the backend.')
  }

  return {
    adminPassword,
    host: env.HOST ?? '127.0.0.1',
    port: env.PORT ? Number(env.PORT) : 3000,
  }
}
