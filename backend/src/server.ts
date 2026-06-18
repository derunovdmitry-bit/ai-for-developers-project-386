import cookie from '@fastify/cookie'
import Fastify from 'fastify'

import type { BackendConfig } from './config.js'
import { ApiDomainError } from './errors.js'
import { registerAdminRoutes } from './routes/admin.js'
import { registerPublicRoutes } from './routes/public.js'
import { createStore } from './store.js'

export function createServer(config: BackendConfig) {
  const app = Fastify({ logger: false })
  const store = createStore()

  void app.register(cookie)
  void registerPublicRoutes(app, store)
  void registerAdminRoutes(app, store, config)

  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof ApiDomainError) {
      return reply.status(error.statusCode).send({
        code: error.code,
        message: error.message,
      })
    }

    return reply.status(500).send({
      code: 'validation-error',
      message: 'Внутренняя ошибка сервера.',
    })
  })

  return app
}
