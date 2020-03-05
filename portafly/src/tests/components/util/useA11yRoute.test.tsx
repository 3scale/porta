import * as React from 'react'
import { Link, Route, Switch } from 'react-router-dom'
import { render } from 'tests/custom-render'
import { useA11yRouteChange } from 'components'
import { fireEvent } from '@testing-library/react'


const SamplePage = () => {
  const containerId = 'test-focus'
  useA11yRouteChange(containerId)
  const [focused, setFocused] = React.useState(false)

  return (
    <div id={containerId} tabIndex={-1} onFocus={() => setFocused(true)}>
      {focused && <div data-testid="test-focused">Focused!</div>}
    </div>
  )
}

it('should focus', () => {
  const { getByTestId, findByTestId, queryByTestId } = render(
    <Switch>
      <Route path="/autofocus/:optionalParam?">
        <SamplePage />
      </Route>
      <Route>
        <Link to="/autofocus" data-testid="link">
          Go to page
        </Link>
      </Route>
    </Switch>
  )

  expect(queryByTestId('test-focused')).toBeNull()

  fireEvent.click(getByTestId('link'))
  return findByTestId('test-focused')
    .then((e) => expect(e).toBeInTheDocument())
})
