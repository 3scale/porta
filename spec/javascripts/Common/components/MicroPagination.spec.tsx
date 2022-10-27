import { mount } from 'enzyme'
import { MicroPagination } from 'Common/components/MicroPagination'
import { Button } from '@patternfly/react-core'

import type { Props } from 'Common/components/MicroPagination'
import type { ReactWrapper } from 'enzyme'

const setPage = jest.fn()
const lastPage = 5

const defaultProps = {
  page: 1,
  lastPage,
  setPage
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<MicroPagination {...{ ...defaultProps, ...props }} />)
const previousPageButton = (wrapper: ReactWrapper<unknown>) => wrapper.find(Button).first()
const nextPageButton = (wrapper: ReactWrapper<unknown>) => wrapper.find(Button).last()

afterEach(() => jest.resetAllMocks())

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

describe('when on the first page', () => {
  const props = { ...defaultProps, page: 1 } as const

  it('should not be able to go to the previous page', () => {
    const wrapper = mountWrapper(props)
    const button = previousPageButton(wrapper)
    expect(button.props().isDisabled).toBe(true)

    button.simulate('click')
    expect(setPage).not.toHaveBeenCalled()
  })

  it('should be able to go to the next page', () => {
    const wrapper = mountWrapper(props)
    const button = nextPageButton(wrapper)
    expect(button.props().isDisabled).toBe(false)

    button.simulate('click')
    expect(setPage).toHaveBeenCalledWith(2)
  })
})

describe('when on the last page', () => {
  const props = { ...defaultProps, page: lastPage } as const

  it('should be able to go to the previous page', () => {
    const wrapper = mountWrapper(props)
    const button = previousPageButton(wrapper)
    expect(button.props().isDisabled).toBe(false)

    button.simulate('click')
    expect(setPage).toHaveBeenCalledWith(lastPage - 1)
  })

  it('should not be able to go to the next page', () => {
    const wrapper = mountWrapper(props)
    const button = nextPageButton(wrapper)
    expect(button.props().isDisabled).toBe(true)

    button.simulate('click')
    expect(setPage).not.toHaveBeenCalled()
  })
})
