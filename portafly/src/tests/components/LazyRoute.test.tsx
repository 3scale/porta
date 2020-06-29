import * as React from 'react'
import { render } from 'tests/custom-render'
import { LazyRoute } from 'components'
import { waitFor } from '@testing-library/react'

const getComponent = () => Promise.resolve({
  default: () => <div data-testid="async-component">Hello!</div>
})
const TestComponent = React.lazy(getComponent)

test('should render a spinner while waiting for a component module to be loaded', async () => {
  const { queryByTestId, getByText } = render(<LazyRoute component={TestComponent} />)
  waitFor(() => expect(getByText('loading.title')).toBeInTheDocument())
  expect(queryByTestId('async-component')).not.toBeInTheDocument()
})

test('should render the async component', async () => {
  const { queryByTestId, getByTestId } = render(<LazyRoute component={TestComponent} />)

  expect(queryByTestId('async-component')).not.toBeInTheDocument()
  waitFor(() => expect(getByTestId('async-component')).toBeInTheDocument())
})
