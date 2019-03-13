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
  it('renders <DocumentationMenu/> component when Saas', () => {
    const wrapper = shallow(<DocumentationMenu {...Props} />)
    expect(wrapper.find('.PopNavigation--docs')).toHaveLength(1)
    expect(wrapper.find('a.PopNavigation-trigger')).toHaveLength(1)
    expect(wrapper.find('ul.PopNavigation-list')).toHaveLength(1)
    expect(wrapper.find(DocumentationMenuItem)).toHaveLength(4)
  })

  it('renders <DocumentationMenu/> component when no Saas', () => {
    let props = Object.assign({}, Props, {isSaas: null})
    const wrapper = shallow(<DocumentationMenu {...props} />)
    expect(wrapper.find('.PopNavigation--docs')).toHaveLength(1)
    expect(wrapper.find('ul.PopNavigation-list')).toHaveLength(1)
    expect(wrapper.find(DocumentationMenuItem)).toHaveLength(3)
  })
})
