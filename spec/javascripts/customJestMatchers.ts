import { expect } from '@jest/globals'
import {
  printExpected,
  printReceived
} from 'jest-matcher-utils'

const toBeWithinSecondsFrom = (actual: Date, expected: Date, seconds = 1) => {
  const diff = Math.abs(expected.getTime() - actual.getTime())
  const pass = diff <= seconds * 1000
  const message = () => `expected ${printReceived(actual)} ${pass ? 'not ' : ''}to be within ${seconds} seconds from ${printExpected(expected)}, but it was within ${diff / 1000} seconds`
  return {
    message,
    pass
  }
}

expect.extend({
  toBeWithinSecondsFrom
})

declare global {
  namespace jest {
    interface Matchers<R> {
      toBeWithinSecondsFrom: (expected: Date, seconds?: number) => R;
    }
  }
}
