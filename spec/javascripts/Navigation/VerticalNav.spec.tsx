import { mount } from 'enzyme'
import { NavItemSeparator } from '@patternfly/react-core'

import { VerticalNav } from 'Navigation/components/VerticalNav'

import type { Item, Section, SubItem } from 'Navigation/types'
import type { Props } from 'Navigation/components/VerticalNav'

const defaultProps: Props = {
  sections: [],
  activeSection: undefined,
  activeItem: undefined,
  currentApi: undefined
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<VerticalNav {...{ ...defaultProps, ...props }} />)

describe('product context', () => {
  const currentApi = {
    id: 1,
    name: 'My Product',
    link: '/foo',
    type: 'product'
  }

  it('should display the current API on top', () => {
    const wrapper = mountWrapper({ currentApi })
    const sectionTitle = wrapper.find('.pf-c-page__sidebar-body > .pf-c-nav__current-api')

    expect(sectionTitle.text()).toBe(currentApi.name)

    wrapper.setProps({ currentApi: undefined })
    expect(wrapper.exists('.pf-c-page__sidebar-body > .pf-c-nav__current-api')).toBe(false)
  })
})

describe('first level items and sections', () => {
  it('should render external links', () => {
    const section: Section = {
      id: 'nav-item-1',
      title: 'External link',
      path: '/items/0',
      target: '_blank'
    }

    const wrapper = mountWrapper({ sections: [section] })

    const link = wrapper.find('.pf-c-nav__item .pf-c-nav__link')
    expect(link.props().target).toEqual(section.target)
    expect(link.props().href).toEqual(section.path)
    expect(link.text()).toEqual(section.title)
  })

  it('should render sections', () => {
    const sections = [
      { id: 'section-0', title: 'Section 0', items: [] },
      { id: 'section-1', title: 'Section 1', items: [] }
    ]
    const wrapper = mountWrapper({ sections })
    wrapper.find('.pf-c-nav .pf-c-nav__list .pf-c-nav__item.pf-m-expandable button.pf-c-nav__link').forEach((button, i) => {
      expect(button.text()).toEqual(sections[i].title)
    })
  })

  it('should render all sections closed by default', () => {
    const sections = [
      { id: 'section-0', title: 'Section 0', items: [] },
      { id: 'section-1', title: 'Section 1', items: [] }
    ]
    const wrapper = mountWrapper({ sections })
    expect(wrapper.exists('.pf-m-expanded')).toEqual(false)
  })

  it('should expand the active section', () => {
    const sections = [
      { id: 'section-0', title: 'Section 0', items: [] },
      { id: 'section-1', title: 'Section 1', items: [] }
    ]
    const { id, title } = sections[0]
    const wrapper = mountWrapper({ sections, activeSection: id })

    expect(wrapper.find('.pf-c-nav__item.pf-m-expandable.pf-m-expanded.pf-m-current').text())
      .toEqual(title)
  })
})

describe('second level items', () => {
  it('should render external links', () => {
    const navItem: Item = {
      id: 'section-0-nav-item-0',
      title: 'External link',
      path: '/section/0/items/0',
      target: '_blank'
    }
    const section: Section = {
      id: 'section-0',
      title: 'Section 0',
      items: [navItem]
    }

    const wrapper = mountWrapper({ sections: [section] })

    const link = wrapper.find('.pf-c-nav__item .pf-c-nav__subnav .pf-c-nav__list a.pf-c-nav__link')
    expect(link.props().target).toEqual(navItem.target)
    expect(link.props().href).toEqual(navItem.path)
    expect(link.text()).toEqual(navItem.title)
  })

  it('should render grouped items', () => {
    const items: Item[] = [
      { id: 'section-0-item-0', title: 'Item 0', path: '/section/0/item/0' },
      { id: 'section-0-item-1', title: 'Item 1', path: '/section/0/item/1' }
    ]
    const section: Section = {
      id: 'section-0',
      title: 'Section 0',
      items
    }

    const wrapper = mountWrapper({ sections: [section] })

    wrapper.find('.pf-c-nav__item.pf-m-expandable .pf-c-nav__subnav a.pf-c-nav__link').forEach((anchor, i) => {
      const { target, path, title } = items[i]
      expect(anchor.props().target).toEqual(target)
      expect(anchor.props().href).toEqual(path)
      expect(anchor.text()).toEqual(title)
    })
  })

  it('should mark a grouped section as out of date', () => {
    const navItem: Item = {
      id: 'section-0-nav-item-0',
      title: 'Outdated Settings',
      path: '/section/0/items/0',
      itemOutOfDateConfig: true
    }
    const section: Section = {
      id: 'section-0',
      title: 'Outdated Section',
      outOfDateConfig: true,
      items: [navItem]
    }

    const wrapper = mountWrapper({ sections: [section] })

    expect(wrapper.find('.pf-c-nav__item.pf-m-expandable').hasClass('outdated-config')).toBe(true)
    expect(wrapper.find('.pf-c-nav__item .pf-c-nav__subnav .pf-c-nav__list a.pf-c-nav__link').hasClass('outdated-config')).toBe(true)

    navItem.itemOutOfDateConfig = false
    section.outOfDateConfig = false
    wrapper.setProps({ sections: [section] })

    expect(wrapper.find('.pf-c-nav__item.pf-m-expandable').hasClass('outdated-config')).toBe(false)
    expect(wrapper.find('.pf-c-nav__item .pf-c-nav__subnav .pf-c-nav__list a.pf-c-nav__link').hasClass('outdated-config')).toBe(false)
  })

  it('should render a separator', () => {
    const navItem: Item = {
      id: 'section-0-nav-separator'
    }
    const section: Section = {
      id: 'section-0',
      title: 'Section 0',
      items: [navItem]
    }

    const wrapper = mountWrapper({ sections: [section] })
    expect(wrapper.find('.pf-c-nav__item .pf-c-nav__subnav').exists(NavItemSeparator)).toEqual(true)
  })

  it('should highlight the active item', () => {
    const sections = [
      { id: 'section-0', title: 'Section 0', items: [{ id: 'section-0-item-0', title: 'Item 0' }] },
      { id: 'section-1', title: 'Section 1', items: [{ id: 'section-1-item-1', title: 'Item 1' }] }
    ]
    const { id: sectionId, items } = sections[0]
    const { id: itemId, title: itemTitle } = items[0]
    const wrapper = mountWrapper({ sections, activeSection: sectionId, activeItem: itemId })

    expect(wrapper.find('.pf-m-expandable.pf-m-current .pf-c-nav__link.pf-m-current').text())
      .toEqual(itemTitle)
  })
})

describe('third level items', () => {
  it('should render external links', () => {
    const subItem: SubItem = {
      id: 'section-0-nav-item-0',
      title: 'External link',
      path: '/section/0/items/0',
      target: '_blank'
    }
    const section: Section = {
      id: 'section-0',
      title: 'Section 0',
      items: [{
        id: 'section-0-nav-item-0',
        title: 'External link',
        subItems: [subItem]
      }]
    }

    const wrapper = mountWrapper({ sections: [section] })

    const link = wrapper.find('.pf-m-expandable .pf-c-nav__subnav .pf-c-nav__subnav a.pf-c-nav__link')
    expect(link.props().target).toEqual(subItem.target)
    expect(link.props().href).toEqual(subItem.path)
    expect(link.text()).toEqual(subItem.title)
  })

  it('should render grouped items', () => {
    const subItems: SubItem[] = [
      { id: 'section-0-nav-item-0-subitem-0', title: 'Subitem 0' },
      { id: 'section-0-nav-item-0-subitem-1', title: 'Subitem 1' }
    ]
    const section: Section = {
      id: 'section-0',
      title: 'Section 0',
      items: [{
        id: 'section-0-nav-item-0',
        title: 'External link',
        subItems
      }]
    }

    const wrapper = mountWrapper({ sections: [section] })

    wrapper.find('.pf-m-expandable .pf-c-nav__subnav .pf-c-nav__subnav a.pf-c-nav__link')
      .forEach((anchor, i) => {
        const { target, path, title } = subItems[i]
        expect(anchor.props().target).toEqual(target)
        expect(anchor.props().href).toEqual(path)
        expect(anchor.text()).toEqual(title)
      })
  })

  it('should highlight the active item', () => {
    const sections: Section[] = [{
      id: 'section-0',
      title: 'Section 0',
      items: [{
        id: 'section-0-nav-item-0',
        title: 'External link',
        subItems: [
          { id: 'section-0-nav-item-0-subitem-0', title: 'Subitem 0' },
          { id: 'section-0-nav-item-0-subitem-1', title: 'Subitem 1' }
        ]
      }]
    }]
    const { id: sectionId, items } = sections[0]
    const { subItems } = items![0]
    const { id: subItemId, title: subItemTitle } = subItems![0]
    const wrapper = mountWrapper({ sections, activeSection: sectionId, activeItem: subItemId })

    expect(wrapper.find('.pf-m-expandable .pf-c-nav__subnav .pf-c-nav__subnav .pf-m-current').text())
      .toEqual(subItemTitle)
  })
})
