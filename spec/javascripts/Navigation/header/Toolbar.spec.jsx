import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { Toolbar } from 'Navigation/components/header/Toolbar'
import { Toolbar as PFToolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'

Enzyme.configure({ adapter: new Adapter() })

const props = {
  toolbarProps: {
    accountSettingsLink: '#',
    accountSettingsClass: 'account-class'
  },
  docsProps: {
    docsLink: '#',
    isSaas: 'true',
    docsLinksClass: 'docs-class',
    customerPortalLink: 'cp-link',
    apiDocsLink: 'api-docs-link',
    liquidReferenceLink: 'liquid-link',
    whatIsNewLink: 'wsn-link'
  }
}

describe('<Toolbar/>', () => {
  it('renders <Toolbar/> component when impersonated', () => {
    const wrapper = shallow(<Toolbar {...props} />)
    expect(wrapper.find(PFToolbar)).toHaveLength(1)
    expect(wrapper.find(ToolbarGroup)).toHaveLength(1)
    expect(wrapper.find(ToolbarItem)).toHaveLength(2)
  })
})
