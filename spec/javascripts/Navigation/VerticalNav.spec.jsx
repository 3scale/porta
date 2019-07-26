// @flow

import React from 'react'
import Enzyme, { shallow, render, mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { VerticalNav } from 'Navigation/components/VerticalNav'

Enzyme.configure({ adapter: new Adapter() })

const items = [
  { id: 'subsection_0', title: 'Subsection 0', path: '/subsection_0' },
  { id: 'subsection_1', title: 'Subsection 1', path: '/subsection_1' }
]
const sectionsWithSubitems = [{ id: 'section_with_subsections', title: 'Section With Subsections', items }]
const sections = [
  { id: 'section_0', title: 'Section 0', path: '/section_0' },
  { id: 'section_1', title: 'Section 1', path: '/section_1' },
  ...sectionsWithSubitems
]
const props = { sections }

it('should render itself', () => {
  const wrapper = render(<VerticalNav {...props} />)
  expect(wrapper.find('nav.pf-c-nav#mainmenu')).toHaveLength(1)
})

it('should render a nav item per section', () => {
  const wrapper = render(<VerticalNav {...props} />)
  expect(wrapper.find('.pf-c-nav__list').children()).toHaveLength(sections.length)
})

it('should render subnav items for sections with subitems', () => {
  const wrapper = render(<VerticalNav {...props} />)

  const subNav = wrapper.find('.pf-c-nav__subnav')
  expect(subNav).toHaveLength(sectionsWithSubitems.length)
  expect(subNav.find('.pf-c-nav__item')).toHaveLength(items.length)
})

it('should expand/collapse sections on click', () => {
  const wrapper = shallow(<VerticalNav sections={sectionsWithSubitems} />)

  const link = wrapper.find('NavExpandable').find('a').first()
  expect(wrapper.find('.pf-expanded').exists()).toBe(false)

  link.simulate('click')
  expect(wrapper.find('.pf-expanded').exists()).toBe(true)

  link.simulate('click')
  expect(wrapper.find('.pf-expanded').exists()).toBe(false)
})

it('should highlight the active section', () => {
  const wrapper = mount(<VerticalNav sections={sections} />)
  expect(wrapper.find('.pf-m-current').exists()).toBe(false)

  const section = sections[0]

  wrapper.setProps({ activeSection: section.id })

  expect(wrapper.find('.pf-m-current').exists()).toBe(true)
  expect(wrapper.find('.pf-m-current').text()).toEqual(section.title)
})

it('should highlight and expand the active section and subsection', () => {
  const wrapper = mount(<VerticalNav sections={sectionsWithSubitems} />)
  expect(wrapper.find('.pf-m-current').exists()).toBe(false)
  expect(wrapper.find('.pf-m-expanded').exists()).toBe(false)

  const section = sectionsWithSubitems[0]
  const subSection = section.items[0]

  wrapper.setProps({ activeSection: section.id, activeItem: subSection.id })
  wrapper.update()

  const expanded = wrapper.find('.pf-m-expanded')
  expect(expanded.exists()).toBe(true)
  expect(expanded.hasClass('pf-m-current')).toBe(true)

  const subNav = expanded.find('.pf-c-nav__subnav')
  expect(subNav.find('.pf-m-current').exists()).toBe(true)
  expect(subNav.find('.pf-m-current').text()).toEqual(subSection.title)
})
