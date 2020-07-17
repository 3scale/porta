import * as React from 'react'
import { render } from 'tests/custom-render'
import { AppLayout, IAppLayoutProps } from 'components'
import { fireEvent } from '@testing-library/react'

function makeAppLayout(
  args: Partial<React.PropsWithChildren<IAppLayoutProps>> = {}
) {
  const props: IAppLayoutProps = {
    logo: <div>App logo</div>,
    headerTools: <div>Toolbar</div>,
    navVariant: 'vertical',
    navItems: [
      {
        title: 'Samples',
        to: '/samples/',
        items: [
          { to: '/samples/foo', title: 'Foo' },
          undefined,
          { to: '/samples/bar', title: 'Bar' },
          { to: '/samples/baz', title: 'Baz' }
        ]
      },
      { to: '/support', title: 'Support' },
      { to: '/something', title: 'Something' }
    ],
    navGroupsStyle: 'expandable',
    startWithOpenNav: true,
    theme: 'dark',
    mainContainerId: 'test-main-container',
    children: <div data-testid="test-content">test</div>,
    ...args
  }
  // eslint-disable-next-line react/jsx-props-no-spreading
  return <AppLayout {...props} />
}

function renderAppLayout(...args: Parameters<typeof makeAppLayout>) {
  return render(makeAppLayout(...args))
}

describe('AppLayout tests', () => {
  test('should render as configured', async () => {
    const { getByTestId, getByText, container } = renderAppLayout()
    getByTestId('test-content')
    getByText('App logo')
    getByText('Toolbar')
    getByTestId('app-sidebar')
    expect(container.querySelector('#test-main-container')).not.toBeNull()
  })

  it('should render a nav-toggle button', async () => {
    const { getByLabelText } = renderAppLayout()
    expect(getByLabelText('Global navigation')).toBeInTheDocument()
  })

  it('should start with collapsed sidebar, then open when clicking the nav-toggle button', async () => {
    const { getByLabelText, getByTestId } = renderAppLayout()
    const navButton = getByLabelText('Global navigation')
    const sidebar = getByTestId('app-sidebar')
    expect(sidebar).toHaveClass('pf-m-collapsed')
    fireEvent.click(navButton)
    expect(sidebar).toHaveClass('pf-m-expanded')
  })
})
