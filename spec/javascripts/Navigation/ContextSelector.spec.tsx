import { mount } from 'enzyme'

import { ContextSelector } from 'Navigation/components/ContextSelector'

import type { Props } from 'Navigation/components/ContextSelector'

const defaultProps = {
  toggle: { title: 'Dashboard', icon: 'home' },
  menuItems: [
    { title: 'Dashboard', href: 'provider_admin_dashboard_path', icon: 'home', disabled: true },
    { title: 'Audience', href: 'audience_link', icon: 'bullseye', disabled: false },
    { title: 'Products', href: 'admin_services_path', icon: 'cubes', disabled: false },
    { title: 'Backends', href: 'provider_admin_backend_apis_path', icon: 'cube', disabled: false },
    { title: 'Account Settings', href: 'settings_link', icon: 'cog', disabled: false }
  ]
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ContextSelector {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-dropdown__toggle[aria-label="Context selector toggle"]').simulate('click')

  expect(wrapper).toMatchSnapshot()
})

it('should open and close', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('ul')).toEqual(false)

  wrapper.find('.pf-c-dropdown__toggle[aria-label="Context selector toggle"]').simulate('click')
  expect(wrapper.exists('ul')).toEqual(true)
})
