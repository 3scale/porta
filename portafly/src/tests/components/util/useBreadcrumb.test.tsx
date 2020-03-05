import * as React from 'react'
import { Link, Route, Switch } from 'react-router-dom'
import { render } from 'tests/custom-render'
import { AppLayout, useBreadcrumb } from 'components'
import { fireEvent } from '@testing-library/react'

const SampleBreadcrumb = <div data-testid="test-breadcrumb">breadcrumb</div>

const SamplePageWithBreadcrumb: React.FunctionComponent = () => {
  useBreadcrumb(SampleBreadcrumb)

  return (
    <div>
      <Link to="/no-breadcrumb" data-testid="go-to-page-without-breadcrumb">
        Go to page without breadcrumb
      </Link>
    </div>
  )
}

describe('useBreadcrumb tests', () => {
  test('should render a breadcrumb, and then remove it if the content changes to a page without a breadcrumb', async () => {
    const { getByTestId, getByText, queryByTestId } = render(
      <AppLayout>
        <Switch>
          <Route path="/" exact>
            <SamplePageWithBreadcrumb />
          </Route>
          <Route path="/no-breadcrumb">page with no breadcrumb</Route>
        </Switch>
      </AppLayout>
    )

    getByTestId('test-breadcrumb')
    getByText('breadcrumb')

    fireEvent.click(getByTestId('go-to-page-without-breadcrumb'))

    getByText('page with no breadcrumb')
    expect(queryByTestId('test-breadcrumb')).toBeNull()
  })
})
