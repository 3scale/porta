import { mount } from 'enzyme'

import { ToolbarSelect } from 'Common/components/ToolbarSelect'
import { mockLocation } from 'utilities/test-utils'

import type { Props } from 'Common/components/ToolbarSelect'

const attribute = 'plan_id'
const collection = [
  { id: '1', title: 'Plan A' },
  { id: '2', title: 'Plan B' },
  { id: '3', title: 'Plan C' }
]

const defaultProps = {
  collection,
  name: `search[${attribute}]`,
  placeholder: 'Select a plan'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ToolbarSelect {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.restoreAllMocks()
})

describe('search is empty', () => {
  beforeEach(() => {
    mockLocation('http://example.com')
  })

  it('should not have any option selected', () => {
    const wrapper = mountWrapper()

    wrapper.find('SelectToggle').simulate('click')
    const options = wrapper.find('SelectOption')

    expect(options.someWhere(o => o.prop('isSelected') === true)).toEqual(false)
  })

  it('should perform a search when selecting an option', () => {
    const { id, title } = collection[0]
    const wrapper = mountWrapper()

    wrapper.find('SelectToggle').simulate('click')
    wrapper.find(`SelectOption[value="${title}"] button`).simulate('click')
    wrapper.update()

    expect(window.location.replace).toHaveBeenCalledWith(`http://example.com/?utf8=%E2%9C%93&search%5B${attribute}%5D=${id}`)
  })
})

describe('ongoing search', () => {
  const selectedOption = collection[0]

  beforeEach(() => {
    mockLocation(`http://example.com/?utf8=%E2%9C%93&search%5B${attribute}%5D=${selectedOption.id}`)
  })

  it('should have an option selected', () => {
    const wrapper = mountWrapper()

    wrapper.find('SelectToggle').simulate('click')
    const options = wrapper.find('SelectOption')
      .findWhere(o => o.prop('isSelected') === true)

    expect(options.length).toEqual(1)
    expect(options.first().props().value).toEqual(selectedOption.title)
  })

  it('should perform a search when selecting a different option', () => {
    const { id, title } = collection[1]
    const wrapper = mountWrapper()

    wrapper.find('SelectToggle').simulate('click')
    wrapper.find(`SelectOption[value="${title}"] button`).simulate('click')
    wrapper.update()

    expect(window.location.replace).toHaveBeenCalledWith(`http://example.com/?utf8=%E2%9C%93&search%5B${attribute}%5D=${id}`)
  })

  it('should be close when selecting the same option', () => {
    const { title } = selectedOption
    const wrapper = mountWrapper()

    wrapper.find('SelectToggle').simulate('click')
    wrapper.find(`SelectOption[value="${title}"] button`).simulate('click')

    expect(wrapper.exists('SelectOption')).toEqual(false)
  })

  it('should be clearable', () => {
    const { title } = selectedOption
    const wrapper = mountWrapper()

    wrapper.find('SelectToggle').simulate('click')
    wrapper.find(`SelectOption[value="${title}"] button`).simulate('click')
    wrapper.update()

    wrapper.find('.pf-c-select .pf-c-select__toggle-clear').simulate('click')
    wrapper.update()

    expect(window.location.replace).toHaveBeenCalledWith('http://example.com/?utf8=%E2%9C%93')
  })
})
