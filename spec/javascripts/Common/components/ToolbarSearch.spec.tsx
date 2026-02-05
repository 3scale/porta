import { mount } from 'enzyme'
import { Popover } from '@patternfly/react-core'

import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { updateInput } from 'utilities/test-utils'
import * as navigation from 'utilities/navigation'

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

  it('should display the Popover if input has less than 3 characters', () => {
    const value = 'ab'

    updateInput(wrapper, value, 'SearchInput input')
    wrapper.find('button[type="submit"]').simulate('click')

    expect(wrapper.find(Popover).props().isVisible).toBe(true)
  })

  it('should not replace when clearing the input if search is not submitted', () => {
    wrapper.find('button[aria-label="Reset"]').simulate('click')

    expect(navigation.replace).not.toHaveBeenCalled()
  })
})

describe('when a search has been submitted', () => {
  it('should submit search and replace if input has more than 3 characters', () => {
    const value = 'abc'
    const wrapper = mountWrapper()

    updateInput(wrapper, value, 'SearchInput input')
    wrapper.find('button[type="submit"]').simulate('click')

    expect(wrapper.find(Popover).props().isVisible).toBe(false)
    expect(navigation.replace).toHaveBeenCalledWith(`http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=${value}`)
  })

  it('should replace with empty search when clearing the input if search is submitted', () => {
    jest.spyOn(URLSearchParams.prototype, 'get').mockReturnValueOnce('abc')
    const wrapper = mountWrapper()

    wrapper.find('button[aria-label="Reset"]').simulate('click')

    expect(navigation.replace).toHaveBeenCalledWith('http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=')
  })
})
