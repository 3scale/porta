import { mount } from 'enzyme'

import { FancySelect } from 'Common/components/FancySelect'

import type { ReactWrapper } from 'enzyme'
import type { Props } from 'Common/components/FancySelect'
import type { IRecord } from 'Types'

const onSelect = jest.fn()

type CrewMember = IRecord & { role: string }

const items: CrewMember[] = [
  { id: 0, name: 'J. Holden', role: 'Captain' },
  { id: 1, name: 'N. Nagata', role: 'Engineer' },
  { id: 2, name: 'A. Kamal', role: 'Pilot' }
]

const NAME = 'the_captain'

const defaultProps: Props<CrewMember> = {
  item: undefined,
  items,
  onSelect,
  label: 'Rocinante',
  id: 'fancy_select',
  header: 'Most recent crew members',
  isDisabled: undefined,
  name: NAME,
  helperText: undefined,
  helperTextInvalid: undefined,
  placeholderText: undefined,
  footer: undefined
}

const mountWrapper = (props: Partial<Props<CrewMember>> = {}) => mount(<FancySelect {...{ ...defaultProps, ...props }} />)

const expandSelect = (wrapper: ReactWrapper<unknown>) => wrapper.find('.pf-c-select__toggle-button').simulate('click')

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should select an item', () => {
  const targetItem = items[0]
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').filterWhere(n => n.text().includes(targetItem.name)).simulate('click')

  expect(onSelect).toHaveBeenCalledWith(targetItem)
})

it('should have a default item selected', () => {
  const targetItem = items[0]
  const wrapper = mountWrapper({ item: targetItem })

  const input = wrapper.find(`input[name="${NAME}"]`)
  expect(input.exists()).toEqual(true)
  expect(input.prop('value')).toBe(targetItem.id)
})

it('should have a helper text', () => {
  // eslint-disable-next-line react/no-unescaped-entities
  const wrapper = mountWrapper({ helperText: <p>I'm helpful</p> })
  expect(wrapper.find('.pf-c-form__helper-text').children()).toMatchInlineSnapshot('null')
})

describe('with a sticky footer link', () => {
  const onFooterClick = jest.fn()
  const footer = { label: 'See all available crew', onClick: onFooterClick } as const

  it('should have a link at the bottom', () => {
    const wrapper = mountWrapper({ footer })
    expandSelect(wrapper)

    const footerOption = wrapper.find('.pf-c-select__menu .pf-c-select__menu-footer button')
    expect(footerOption.exists()).toEqual(true)
    expect(footerOption.text()).toEqual(footer.label)

    footerOption.simulate('click')
    expect(onFooterClick).toHaveBeenCalledTimes(1)
  })
})
