import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { DocumentationMenu } from 'Navigation/components/header/DocumentationMenu'
import { DocumentationMenuItem } from 'Navigation/components/header/DocumentationMenuItem'

Enzyme.configure({ adapter: new Adapter() })

const Props = {
  docsLink: 'docs-link',
  isSaas: 'true',
  docsLinksClass: 'docs-class',
  customerPortalLink: 'cp-link',
  apiDocsLink: 'apidocs-link',
  liquidReferenceLink: 'lr-link',
  whatIsNewLink: 'ws-new-link'
}

describe('<DocumentationMenu/>', () => {
  it('should render four <DocumentationMenuItem/> when Saas', () => {
    const wrapper = shallow(<DocumentationMenu {...Props} />)
    expect(wrapper.exists('.PopNavigation--docs')).toEqual(true)
    expect(wrapper.find('a.PopNavigation-trigger').hasClass(Props.docsLink)).toEqual(true)
    expect(wrapper.exists('ul.PopNavigation-list')).toEqual(true)
    expect(wrapper.find(DocumentationMenuItem)).toHaveLength(4)
  })

  it('should render three <DocumentationMenuItem/> when not Saas', () => {
    let props = Object.assign({}, Props, {isSaas: null})
    const wrapper = shallow(<DocumentationMenu {...props} />)
    expect(wrapper.find(DocumentationMenuItem)).toHaveLength(3)
  })
})
