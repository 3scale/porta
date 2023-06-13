import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'
import { Popover, SearchInput } from '@patternfly/react-core'

import { SearchInputWithSubmitButton } from 'Common/components/SearchInputWithSubmitButton'
import { mockLocation } from 'utilities/test-utils'

import type { Props } from 'Common/components/SearchInputWithSubmitButton'

const defaultProps = {
  placeholder: ''
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<SearchInputWithSubmitButton {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

describe('Popover is or is not visible', () => {
  const event = {} as React.FormEvent<HTMLInputElement>
  const wrapper = mountWrapper()

  it('should display the Popover if input has less than 3 characters', () => {
    const value = 'ab'

    act(() => { wrapper.find(SearchInput).props().onChange!(event, value) })
    wrapper.update()

    const button = wrapper.find('button[type="submit"]')
    button.simulate('click')

    expect(wrapper.find(Popover).props().isVisible).toBe(true)
  })

  it('should not display the Popover if input has more than 3 characters', () => {
    const value = 'abc'

    act(() => { wrapper.find(SearchInput).props().onChange!(event, value) })
    wrapper.update()

    const button = wrapper.find('button[type="submit"]')
    button.simulate('click')

    expect(wrapper.find(Popover).props().isVisible).toBe(false)
  })
})

describe('Replace when search has or has not been submitted', () => {
  const event = {} as React.FormEvent<HTMLInputElement>
  const wrapper = mountWrapper()
  mockLocation('http://example.com')

  it('should not replace when clearing the input if search is not submitted', () => {
    const value = 'abc'

    act(() => { wrapper.find(SearchInput).props().onChange!(event, value) })
    wrapper.update()

    const clearButton = wrapper.find('button[aria-label="Reset"]')
    clearButton.simulate('click')

    // expect(clearButton.exists()).toBe(false)
    expect(window.location.replace).not.toHaveBeenCalled()
  })

  it('should replace if search is submitted', () => {
    const value = 'abc'

    act(() => { wrapper.find(SearchInput).props().onChange!(event, value) })
    wrapper.update()

    const button = wrapper.find('button[type="submit"]')
    button.simulate('click')

    expect(window.location.replace).toHaveBeenCalledWith(`http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=${value}`)
  })

  it('should replace with empty search when clearing the input if search is submitted', () => {
    const value = 'abc'

    act(() => { wrapper.find(SearchInput).props().onChange!(event, value) })
    wrapper.update()

    const button = wrapper.find('button[type="submit"]')
    button.simulate('click')

    expect(window.location.replace).toHaveBeenCalledWith(`http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=${value}`)

    const clearButton = wrapper.find('button[aria-label="Reset"]')
    clearButton.simulate('click')

    expect(window.location.replace).toHaveBeenCalledWith('http://example.com/?utf8=%E2%9C%93&search%5Bquery%5D=')
  })
})
