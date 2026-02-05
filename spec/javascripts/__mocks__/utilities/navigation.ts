/**
 * Mock this module because jsdom does not support navigation and it throws console errors.
 */
export const navigate = jest.fn()

export const replace = jest.fn()
