import * as vite from 'vitest/config'

console.log('loading vitest config')

export default vite.defineConfig({
  test: {
    clearMocks: true,
  },
})
