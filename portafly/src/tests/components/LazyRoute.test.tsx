import * as React from 'react'
import { render, waitForElement } from '@test/setup'
import { LazyRoute } from '@src'

describe('LazyRoute tests', () => {
  test('should render a spinner while waiting for a component module to be loaded', async () => {
    expect.assertions(1)
    const getComponent = () => {
      expect(true).toBe(true)
      return new Promise<{ default: React.ComponentType }>(() => {})
    }
    const { getByText } = render(<LazyRoute getComponent={getComponent} />)
    await waitForElement(() => getByText('Loading'))
  })

  test('should render the async component', async () => {
    const getComponent = () =>
      Promise.resolve({ default: () => <div>content</div> })
    const { getByText } = render(<LazyRoute getComponent={getComponent} />)
    await waitForElement(() => getByText('content'))
  })
})
