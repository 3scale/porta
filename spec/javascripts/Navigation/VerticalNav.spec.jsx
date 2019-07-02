import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { VerticalNav } from 'Navigation/components/VerticalNav'

Enzyme.configure({ adapter: new Adapter() })

const props = {
  sections: [
    { id: 'Foo', title: 'Foo', path: '/foo' },
    { id: 'Bar', title: 'Bar', path: '/bar' },
    {
      id: 'BazQux',
      title: 'BazQux',
      items: [
        { id: 'Baz', title: 'Baz', path: '/baz' },
        { id: 'Qux', title: 'Qux', path: '/qux' }
      ]
    }
  ],
  activeSection: 'BazQux',
  activeItem: 'Baz'
}

it('should render itself', () => {
  const wrapper = mount(<VerticalNav {...props} />)
  expect(wrapper.find('.pf-c-page__sidebar-body').exists()).toEqual(true)
})

it('should render right markup with submenus', () => {
  const wrapper = mount(<VerticalNav {...props} />)
  const items = wrapper.find('.pf-c-nav__item')
  const links = wrapper.find('.pf-c-nav__link')
  const subLinks = wrapper.find('section .pf-c-nav__link')
  expect(items.length).toBe(5)
  expect(links.length).toBe(5)
  expect(subLinks.length).toBe(2)
})

it('should render right markup without submenus', () => {
  const propsNoSubmenus = {
    sections: [
      { id: 'Foo', title: 'Foo', path: '/foo' },
      { id: 'Bar', title: 'Bar', path: '/bar' },
    ],
    activeSection: 'Foo',
    activeItem: null
  }

  const wrapper = mount(<VerticalNav {...propsNoSubmenus} />)
  const items = wrapper.find('.pf-c-nav__item')
  const links = wrapper.find('.pf-c-nav__link')
  const subLink = wrapper.find('section .pf-c-nav__link')
  expect(items.length).toBe(2)
  expect(links.length).toBe(2)
  expect(subLink.exists()).toBe(false)
})
