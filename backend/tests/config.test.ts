import { describe, expect, it } from 'vitest'

import { readConfig } from '../src/config.js'

describe('readConfig', () => {
  it('throws a clear error when ADMIN_PASSWORD is missing', () => {
    expect(() => readConfig({})).toThrow(
      'ADMIN_PASSWORD is required to start the backend.',
    )
  })

  it('reads ADMIN_PASSWORD and default server settings', () => {
    expect(readConfig({ ADMIN_PASSWORD: 'secret' })).toEqual({
      adminPassword: 'secret',
      host: '127.0.0.1',
      port: 3000,
    })
  })
})
