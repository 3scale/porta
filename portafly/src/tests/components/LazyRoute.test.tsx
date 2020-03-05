import * as React from 'react'
import { render } from 'tests/custom-render'
import { LazyRoute } from 'components'
import { waitForElement } from '@testing-library/react'

const getComponent = () => Promise.resolve({
  default: () => <div data-testid="async-component">Hello!</div>
})

test('should render a spinner while waiting for a component module to be loaded', () => {
  const { queryByTestId, getByText } = render(<LazyRoute getComponent={getComponent} />)
  expect(getByText('Loading')).toBeInTheDocument()
  expect(queryByTestId('async-component')).not.toBeInTheDocument()
})

test('should render the async component', async () => {
  const { queryByTestId, getByTestId } = render(<LazyRoute getComponent={getComponent} />)

  expect(queryByTestId('async-component')).not.toBeInTheDocument()
  waitForElement(() => expect(getByTestId('async-component')).toBeInTheDocument())
})
