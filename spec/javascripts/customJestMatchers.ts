import { expect } from '@jest/globals'
import {
  printExpected,
  printReceived
} from 'jest-matcher-utils'

const toBeWithinSecondsFrom = (actual: Date, expected: Date, seconds = 1) => {
  const diff = Math.abs(expected.getSeconds() - actual.getSeconds())
  const pass = diff <= seconds
  const message = () => `expected ${printReceived(actual)} ${pass ? 'not ' : ''}to be within ${seconds} seconds from ${printExpected(expected)}, but it was within ${diff} seconds`
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
