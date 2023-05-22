import { mount } from 'enzyme'

import { Masthead } from 'Navigation/components/Masthead'

import type { Props } from 'Navigation/components/Masthead'

const defaultProps: Props = {
  apiDocsHref: '',
  brandHref: '',
  contextSelectorProps: {
    activeMenu: 'dashboard',
    backendsLink: '',
    productsLink: '',
    settingsLink: '',
    audienceLink: undefined
  },
  currentAccount: 'account',
  currentUser: 'user',
  impersonating: undefined,
  liquidReferenceHref: '',
  quickstartsHref: null,
  saas: undefined,
  signOutHref: ''
}

const mountWrapper = (props?: Partial<Props>) => mount(<Masthead {...{ ...defaultProps, ...props }} />)

it('should render', () => {
  const wrapper = mountWrapper()

  // The parent class is included in the slim template
  expect(wrapper.exists('.pf-c-masthead')).toEqual(false)

  expect(wrapper.exists('.pf-c-masthead__main')).toEqual(true)
  expect(wrapper.exists('.pf-c-masthead__content')).toEqual(true)
})

it('should feature a Context selector', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('.pf-c-dropdown__toggle[aria-label="Context selector toggle"]')).toEqual(true)
})

describe('Brand', () => {
  it('should link to the dashboard', () => {
    const brandHref = '/p/admin/dashboard'
    const wrapper = mountWrapper({ brandHref })

    expect(wrapper.exists(`a.pf-c-masthead__brand[href="${brandHref}"]`)).toEqual(true)
  })
})

describe('Documentation menu', () => {
  it('should feature all default items', () => {
    const wrapper = mountWrapper()
    wrapper.find('.pf-c-dropdown__toggle[aria-label="Documentation toggle"]').simulate('click')
    expect(wrapper.find('[title="Documentation"] .pf-c-dropdown__menu-item')).toMatchSnapshot()
  })

  it('should feature a link to news when on saas', () => {
    const wrapper = mountWrapper({ saas: true })
    wrapper.find('.pf-c-dropdown__toggle[aria-label="Documentation toggle"]').simulate('click')
    expect(wrapper.find('[title="Documentation"] .pf-c-dropdown__menu-item')).toMatchSnapshot()
  })

  it('should feature a link to quickstarts when enabled', () => {
    const wrapper = mountWrapper({ quickstartsHref: '/quickstarts' })
    wrapper.find('.pf-c-dropdown__toggle[aria-label="Documentation toggle"]').simulate('click')
    expect(wrapper.find('[title="Documentation"] .pf-c-dropdown__menu-item')).toMatchSnapshot()
  })

  it('should feature all links when enabled', () => {
    const wrapper = mountWrapper({ saas: true, quickstartsHref: '/quickstarts' })
    wrapper.find('.pf-c-dropdown__toggle[aria-label="Documentation toggle"]').simulate('click')
    expect(wrapper.find('[title="Documentation"] .pf-c-dropdown__menu-item')).toMatchSnapshot()
  })
})

describe('Session menu', () => {
  it('should feature a bold icon when impersonating', () => {
    const wrapper = mountWrapper({ impersonating: false })
    expect(wrapper.find('.pf-c-dropdown[title="Session"]').exists('BoltIcon')).toEqual(false)

    wrapper.setProps({ impersonating: true })
    expect(wrapper.find('.pf-c-dropdown[title="Session"]').exists('BoltIcon')).toEqual(true)
  })

  it('should describe who is currently signed in', () => {
    const wrapper = mountWrapper({ currentUser: 'admin', currentAccount: 'Provider' })
    wrapper.find('.pf-c-dropdown__toggle[aria-label="Session toggle"]').simulate('click')

    expect(wrapper.find('[title="Session"] .pf-c-dropdown__menu-item')).toMatchSnapshot()

    wrapper.setProps({ impersonating: true })
    expect(wrapper.find('[title="Session"] .pf-c-dropdown__menu-item')).toMatchSnapshot()
  })
})
