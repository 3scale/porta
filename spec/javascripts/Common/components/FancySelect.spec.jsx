// @flow

import React from 'react'
import { mount } from 'enzyme'

import { FancySelect } from 'Common'

const onSelect = jest.fn()

const items = [
  { id: 0, name: 'J. Holden', role: 'Captain' },
  { id: 1, name: 'N. Nagata', role: 'Engineer' },
  { id: 2, name: 'A. Kamal', role: 'Pilot' }
]

const name = 'the_captain'

const defaultProps = {
  item: null,
  items,
  onSelect,
  label: 'Rocinante',
  id: 'fancy_select',
  header: 'Most recent crew members',
  isDisabled: undefined,
  isValid: undefined,
  name,
  helperText: undefined,
  helperTextInvalid: undefined,
  placeholderText: undefined,
  footer: undefined
}

const mountWrapper = (props) => mount(<FancySelect {...{ ...defaultProps, ...props }} />)

const expandSelect = (wrapper) => wrapper.find('.pf-c-select__toggle-button').simulate('click')

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should select an item', () => {
  const targetItem = items[0]
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').filterWhere(n => n.text().includes(targetItem.name)).simulate('click')

  expect(onSelect).toBeCalledWith(targetItem)
})

it('should have a default item selected', () => {
  const targetItem = items[0]
  const wrapper = mountWrapper({ item: targetItem })

  const input = wrapper.find(`input[name="${name}"]`)
  expect(input.exists()).toBe(true)
  expect(input.prop('value')).toBe(targetItem.id)
})

it('should have a helper text', () => {
  const wrapper = mountWrapper({ helperText: <p>I'm helpful</p> })
  expect(wrapper.find('.pf-c-form__helper-text').children()).toMatchInlineSnapshot(`
    <p>
      I'm helpful
    </p>
  `)
})

describe('with a sticky footer link', () => {
  const onFooterClick = jest.fn()
  const footer = { label: 'See all available crew', onClick: onFooterClick }

  it('should have a link at the bottom', () => {
    const wrapper = mountWrapper({ footer })
    expandSelect(wrapper)

    const footerOption = wrapper.find('button.pf-c-select__menu-item--sticky-footer')
    expect(footerOption.exists())
    expect(footerOption.text()).toEqual(footer.label)

    footerOption.simulate('click')
    expect(onFooterClick).toHaveBeenCalledTimes(1)
  })
})

// describe('with 20 items or less', () => {
//   const items = new Array(20).fill({}).map((i, j) => ({ id: j, name: `Mr. ${j}` }))

//   it('should display all items and a title, but no sticky footer', () => {
//     const wrapper = mountWrapper({ items })
//     wrapper.find('.pf-c-select__toggle-button').simulate('click')
//     expect(wrapper.find('.pf-c-select__menu li').length).toEqual(items.length + 1)
//   })

//   it('should not be able to show a modal', () => {
//     const wrapper = mountWrapper({ items })
//     expect(wrapper.find('TableModal').props().isOpen).toBe(false)

//     wrapper.find('.pf-c-select__toggle-button').simulate('click')
//     expect(wrapper.find('.pf-c-select__menu li button.pf-c-select__menu-item--sticky-footer').exists()).toBe(false)
//   })
// })

// describe('with more than 20 items', () => {
//   const items = new Array(21).fill({}).map((i, j) => ({ id: j, name: `Mr. ${j}` }))

//   it('should display up to 20 items, a title and a sticky footer', () => {
//     const wrapper = mountWrapper({ items })
//     wrapper.find('.pf-c-select__toggle-button').simulate('click')
//     expect(wrapper.find('.pf-c-select__menu li').length).toEqual(22)
//   })

//   it('should be able to show a modal', () => {
//     const wrapper = mountWrapper({ items })
//     expect(wrapper.find('TableModal').props().isOpen).toBe(false)

//     openModal(wrapper)
//     expect(wrapper.find('TableModal').props().isOpen).toBe(true)
//     expect(onSelect).toBeCalledTimes(0)
//   })

//   it('should be able to select an option from the modal', () => {
//     const wrapper = mountWrapper({ items })

//     openModal(wrapper)
//     wrapper.find('input[type="radio"]').first().simulate('change', { value: true })
//     wrapper.find('button[data-testid="select"]').simulate('click')

//     expect(onSelect).toHaveBeenCalledWith(items[0])
//   })

//   it('should display all columns in the modal', () => {
//     const wrapper = mountWrapper({ items })

//     openModal(wrapper)
//     const ths = wrapper.find('table th')

//     cells.forEach(c => (
//       expect(ths.find(`[data-label="${c.title}"]`).exists()).toBe(true)
//     ))
//   })
// })

describe('with no items', () => {
  it('should show an empty message that is disabled', () => {
    const wrapper = mountWrapper({ items: [] })
    wrapper.find('.pf-c-select__toggle-button').simulate('click')

    const items = wrapper.find('SelectOption')
    expect(items.length).toEqual(2)

    const emptyItem = items.last()
    expect(emptyItem.prop('isDisabled')).toBe(true)
    expect(emptyItem.text()).toEqual('No results found')
  })
})
