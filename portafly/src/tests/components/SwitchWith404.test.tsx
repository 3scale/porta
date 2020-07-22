import * as React from 'react'
import { Link, Route, Switch } from 'react-router-dom'
import { fireEvent } from '@testing-library/react'
import { render } from 'tests/custom-render'
import { SwitchWith404 } from 'components'

describe('SwitchWith404 tests', () => {
  test('should render the NotFound component for unmatched routes', async () => {
    const { getByText } = render(
      <SwitchWith404>
        <Route path="/foo">
          <Link to="/broken">Broken link</Link>
        </Route>
      </SwitchWith404>,
      { router: { initialEntries: ['/foo'], initialIndex: 0 } }
    )
    const brokenLink = getByText('Broken link')
    fireEvent.click(brokenLink)
    expect(getByText("404! This view hasn't been created yet.")).not.toBeUndefined()
  })

  test('should render the NotFound component for unmatched routes in nested routes', async () => {
    const { getByText } = render(
      <Switch>
        <Route path="/nested">
          <SwitchWith404>
            <Route path="/nested/deep">
              <Link to="/nested/broken">Broken link</Link>
            </Route>
          </SwitchWith404>
        </Route>
        <Route>ttt</Route>
      </Switch>,
      { router: { initialEntries: ['/nested/deep'], initialIndex: 0 } }
    )
    const brokenLink = getByText('Broken link')
    fireEvent.click(brokenLink)
    expect(getByText("404! This view hasn't been created yet.")).not.toBeUndefined()
  })
})
