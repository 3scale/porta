import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { Header } from 'Navigation/components/header/index'
import { PageHeader } from '@patternfly/react-core'

Enzyme.configure({ adapter: new Adapter() })

const Props = {
  toolbarProps: {
    accountSettingsLink: 'accountSettingsLink',
    accountSettingsClass: 'accountSettingsClass'
  },
  docsProps: {
    docsLink: 'docsLink',
    isSaas: 'true',
    docsLinksClass: 'docsLinksClass',
    customerPortalLink: 'customerPortalLink',
    apiDocsLink: 'apiDocsLink',
    liquidReferenceLink: 'liquidReferenceLink',
    whatIsNewLink: 'whatIsNewLink'
  },
  avatarProps: {
    avatarLinkClass: 'avatarLinkClass',
    impersonated: 'true',
    accountName: 'accountName',
    displayName: 'displayName',
    logoutPath: 'logoutPath',
    username: 'username'
  },
  logoProps: {
    href: '#',
    title: 'Dashboard',
    target: '_self',
    className: `Header-link`
  }
}

describe('<Header/>', () => {
  it('renders <Header/> component', () => {
    const wrapper = shallow(<Header {...Props} />)
    expect(wrapper.props()).toHaveProperty('logo')
    expect(wrapper.props()).toHaveProperty('logoProps')
    expect(wrapper.props()).toHaveProperty('toolbar')
    expect(wrapper.props()).toHaveProperty('avatar')
    expect(wrapper.find(PageHeader)).toHaveLength(1)
  })
})
