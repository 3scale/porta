import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { AccountSettingsMenu, DocumentationMenu, Toolbar } from 'Navigation/components/header/'
import { Toolbar as PFToolbar, ToolbarGroup, ToolbarItem } from '@patternfly/react-core'

Enzyme.configure({ adapter: new Adapter() })

const props = {
  accountSettingsProps: {
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
  it('should render with proper children', () => {
    const wrapper = shallow(<Toolbar {...props} />)
    expect(wrapper.exists(PFToolbar)).toEqual(true)
    expect(wrapper.exists(ToolbarGroup)).toEqual(true)
    expect(wrapper.exists(ToolbarItem)).toEqual(true)
    expect(wrapper.find(ToolbarItem)).toHaveLength(2)
    expect(wrapper.exists(AccountSettingsMenu)).toEqual(true)
    expect(wrapper.exists(DocumentationMenu)).toEqual(true)
  })
})
