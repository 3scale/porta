import * as React from 'react'
import { render, fireEvent } from '@test/setup'
import { AppLayout, IAppLayoutProps } from '@src'

function makeAppLayout(
  props: Partial<React.PropsWithChildren<IAppLayoutProps>> = {}
) {
  props = Object.assign(
    {
      logo: <div>App logo</div>,
      avatar: <div>Avatar</div>,
      toolbar: <div>Toolbar</div>,
      navVariant: 'vertical',
      navItems: [
        {
          title: 'Samples',
          to: '/samples/',
          items: [
            { to: '/samples/foo', title: 'Foo' },
            undefined,
            { to: '/samples/bar', title: 'Bar' },
            { to: '/samples/baz', title: 'Baz' },
          ],
        },
        { to: '/support', title: 'Support' },
        { to: '/something', title: 'Something' },
      ],
      navGroupsStyle: 'expandable',
      startWithOpenNav: true,
      theme: 'dark',
      mainContainerId: 'test-main-container',
      children: <div data-testid={'test-content'}>test</div>,
    },
    props
  )
  return <AppLayout {...(props as IAppLayoutProps)} />
}

function renderAppLayout(...args: Parameters<typeof makeAppLayout>) {
  return render(makeAppLayout(...args))
}

describe('AppLayout tests', () => {
  test('should render as configured', async () => {
    const { getByTestId, getByText, container } = renderAppLayout()
    getByTestId('test-content')
    getByText('App logo')
    getByText('Avatar')
    getByText('Toolbar')
    getByTestId('app-sidebar')
    expect(container.querySelector('#test-main-container')).not.toBeNull()
  })

  it('should render a nav-toggle button', async () => {
    const { getByLabelText } = renderAppLayout()
    getByLabelText('Global navigation')
  })

  it('should hide the sidebar when clicking the nav-toggle button', async () => {
    const { getByLabelText, getByTestId } = renderAppLayout()
    const navButton = getByLabelText('Global navigation')
    const sidebar = getByTestId('app-sidebar')
    expect(sidebar).toHaveClass('pf-m-expanded')
    fireEvent.click(navButton)
    expect(sidebar).toHaveClass('pf-m-collapsed')
  })

  it('should start with an hidden sidebar', async () => {
    const { getByTestId } = renderAppLayout({ startWithOpenNav: false })
    const sidebar = getByTestId('app-sidebar')
    expect(sidebar).toHaveClass('pf-m-collapsed')
  })
})
