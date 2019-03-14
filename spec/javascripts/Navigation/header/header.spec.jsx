import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { Header } from 'Navigation/components/header/index'
import { Brand, SessionMenu, Toolbar } from 'Navigation/components/header'
import { PageHeader } from '@patternfly/react-core'

Enzyme.configure({ adapter: new Adapter() })

const props = {
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
  it('should render a <PageHeader/> component with right props', () => {
    const wrapper = shallow(<Header {...props} />)
    expect(wrapper.exists(PageHeader)).toEqual(true)
    const pageHeader = wrapper.find(PageHeader)
    expect(pageHeader.props().logo).toEqual(<Brand/>)
    expect(pageHeader.props().logoProps).toEqual(props.logoProps)
    expect(pageHeader.props().toolbar).toEqual(<Toolbar accountSettingsProps={props.accountSettingsProps} docsProps={props.docsProps}/>)
    expect(pageHeader.props().avatar).toEqual(<SessionMenu {...props.avatarProps}/>)
  })
})
