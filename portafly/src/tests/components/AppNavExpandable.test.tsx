import * as React from 'react'
import { Link } from 'react-router-dom'
import { render } from 'tests/custom-render'
import { AppNavExpandable } from 'components'
import { fireEvent } from '@testing-library/react'

describe('AppNavExpandable tests', () => {
  test('should render', async () => {
    const { getByText, getByTestId } = render(
      <div>
        <AppNavExpandable
          title="Group title"
          to="/group"
          items={[
            { to: '/group/foo', title: 'foo' },
            { to: '/group/bar', title: 'bar' }
          ]}
        />
        <Link to="/group/foo" data-testid="go-to-foo">
          Go to foo
        </Link>
      </div>
    )

    const groupTitle = getByText('Group title')
    expect(getByText('foo').closest('a')).toHaveAttribute('href', '/group/foo')
    expect(getByText('bar').closest('a')).toHaveAttribute('href', '/group/bar')

    expect(groupTitle.closest('a')).toHaveAttribute('aria-expanded', 'false')

    fireEvent.click(getByTestId('go-to-foo'))

    expect(groupTitle.closest('a')).toHaveAttribute('aria-expanded', 'true')
  })
})
