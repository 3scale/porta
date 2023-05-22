import { mount } from 'enzyme'

import { ContextSelector } from 'Navigation/components/ContextSelector'

import type { Props } from 'Navigation/components/ContextSelector'
import type { Menu } from 'Types'

const audienceLink = '/audience'
const productsLink = '/products'
const backendsLink = '/backends'
const settingsLink = '/settings'

const defaultProps = {
  activeMenu: '' as Menu,
  audienceLink: audienceLink,
  productsLink: productsLink,
  backendsLink: backendsLink,
  settingsLink: settingsLink
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ContextSelector {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-dropdown__toggle[aria-label="Context selector toggle"]').simulate('click')

  expect(wrapper).toMatchSnapshot()
})

it('should not have Audience if not provided', () => {
  const wrapper = mountWrapper({ audienceLink: undefined })
  wrapper.find('.pf-c-dropdown__toggle[aria-label="Context selector toggle"]').simulate('click')

  expect(wrapper).toMatchSnapshot()
})

it('should disable the selected context', () => {
  const wrapper = mountWrapper({ activeMenu: 'dashboard' })
  wrapper.find('.pf-c-dropdown__toggle[aria-label="Context selector toggle"]').simulate('click')

  expect(wrapper.find('.pf-c-dropdown__menu')).toMatchSnapshot()
})

it('should display the current api', () => {
  const wrapper = mountWrapper({ activeMenu: 'serviceadmin' })

  expect(wrapper).toMatchSnapshot()
})
