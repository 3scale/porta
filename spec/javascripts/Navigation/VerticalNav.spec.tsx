import { mount, render } from 'enzyme'

import { VerticalNav } from 'Navigation/components/VerticalNav'

const currentApi = {
  id: 1,
  name: 'My Product',
  link: '/foo',
  type: 'product'
}

const sections = [{
  id: '0',
  title: 'Section 0',
  items: [{ id: '0', title: 'Subsection 0' }, { id: '1', title: 'Subsection 1' }],
  outOfDateConfig: false
}]

it('should display the current API on top', () => {
  const wrapper = render(<VerticalNav currentApi={currentApi} sections={sections} />)
  const sectionTitle = wrapper.find('.pf-c-nav__section-title').first()

  expect(sectionTitle.text()).toBe(currentApi.name)
})

it('should display sections', () => {
  const wrapper = render(<VerticalNav sections={sections} />)
  const navItems = wrapper.find('.pf-c-nav__item')

  expect(navItems.length).toBe(sections.length)
})

it('should display all sections closed by default', () => {
  const wrapper = mount(<VerticalNav sections={sections} />)
  expect(wrapper.exists('.pf-m-expanded')).toEqual(false)

  wrapper.setProps({ sections, activeSection: '0', activeItem: '0' })
  wrapper.update()
  expect(wrapper.exists('.pf-m-expanded')).toEqual(true)
})
