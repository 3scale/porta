import * as React from 'react'
import { Link, Route, Switch } from 'react-router-dom'
import { waitForElement } from '@testing-library/dom'
import { render, fireEvent } from '@test/setup'
import { useA11yRouteChange } from '@src'

const SamplePage = () => {
  useA11yRouteChange('test-focus')
  const [focused, setFocused] = React.useState(false)
  const handleFocus = () => {
    setFocused(true)
  }
  return (
    <div id={'test-focus'} tabIndex={-1} onFocus={handleFocus}>
      {focused ? (
        <div data-testid={'test-focused'}>I'm focused!</div>
      ) : (
        'Not in focus yet'
      )}
    </div>
  )
}

describe('useDocumentTitle tests', () => {
  test('should change the document title', async () => {
    const { getByTestId } = render(
      <Switch>
        <Route path={'/autofocus/:optionalParam?'}>
          <SamplePage />
        </Route>
        <Route>
          <Link to={'/autofocus'} data-testid={'link'}>
            Go to page
          </Link>
        </Route>
      </Switch>
    )
    fireEvent.click(getByTestId('link'))
    await waitForElement(() => getByTestId('test-focused'))
  })
})
