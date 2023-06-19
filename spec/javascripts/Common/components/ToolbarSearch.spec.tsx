import { mount } from 'enzyme'
import { Popover } from '@patternfly/react-core'

import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { mockLocation, updateInput } from 'utilities/test-utils'

import type { Props } from 'Common/components/ToolbarSearch'

const defaultProps = {
  placeholder: ''
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ToolbarSearch {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

describe('before a search has been submitted', () => {
  const wrapper = mountWrapper()
  mockLocation('http://example.com')

  it('should display the Popover if input has less than 3 characters', () => {
    const value = 'ab'

    updateInput(wrapper, value, 'SearchInput input')
    wrapper.find('button[type="submit"]').simulate('click')

    expect(wrapper.find(Popover).props().isVisible).toBe(true)
  })

  it('should not replace when clearing the input if search is not submitted', () => {
    wrapper.find('button[aria-label="Reset"]').simulate('click')

    expect(window.location.replace).not.toHaveBeenCalled()
  })
})

describe('when a search has been submitted', () => {
  it('should submit search and replace if input has more than 3 characters', () => {
    const value = 'abc'
    mockLocation('http://example.com/')
    const wrapper = mountWrapper()

    updateInput(wrapper, value, 'SearchInput input')
    wrapper.find('button[type="submit"]').simulate('click')

    expect(wrapper.find(Popover).props().isVisible).toBe(false)
    expect(window.location.replace).toHaveBeenCalledWith(`http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=${value}`)
  })

  it('should replace with empty search when clearing the input if search is submitted', () => {
    mockLocation('http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=abc')
    const wrapper = mountWrapper()

    wrapper.find('button[aria-label="Reset"]').simulate('click')

    expect(window.location.replace).toHaveBeenCalledWith('http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=')
  })
})
