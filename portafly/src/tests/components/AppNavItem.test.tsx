import * as React from 'react'
import { render } from 'tests/custom-render'
import { AppNavItem } from 'components'

describe('AppNavItem tests', () => {
  test('should render a separator if no title and link is passed', async () => {
    const { getByTestId, rerender } = render(<AppNavItem />)
    getByTestId('navitem-separator')

    rerender(<AppNavItem title="something" />)
    getByTestId('navitem-separator')

    rerender(<AppNavItem to="something" />)
    getByTestId('navitem-separator')
  })

  test('should render a link if a valid title and link is passed', async () => {
    const { getByText } = render(
      <AppNavItem to="/something" title="Link to something" />
    )

    expect(getByText('Link to something').closest('a')).toHaveAttribute(
      'href',
      '/something'
    )
  })
})
