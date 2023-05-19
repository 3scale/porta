import { mount } from 'enzyme'

import { Pagination } from 'Common/components/Pagination'
import { mockLocation } from 'utilities/test-utils'

import type { Props } from 'Common/components/Pagination'

const defaultProps = {
  itemCount: undefined,
  variant: undefined
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<Pagination {...{ ...defaultProps, ...props }} />)

it('should render', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('.pf-c-pagination').exists()).toEqual(true)
})

it('should get page info from URL', () => {
  const itemCount = 100
  const page = 2
  const perPage = 25
  mockLocation(`http://example.com?page=${page}&per_page=${perPage}`)

  const wrapper = mountWrapper({ itemCount })
  expect(wrapper.find('.pf-c-options-menu__toggle-text').text()).toEqual('26 - 50 of 100 ')
  expect(wrapper.find('.pf-c-pagination [aria-label="Current page"]').first().prop('value')).toBe(2)
})

it('should show 20 items per page by default', () => {
  const itemCount = 100
  mockLocation('http://example.com')

  const wrapper = mountWrapper({ itemCount })
  expect(wrapper.find('.pf-c-options-menu__toggle-text').text()).toEqual('1 - 20 of 100 ')
})

it('should be able to jump from page to page', () => {
  const itemCount = 100
  const page = 2
  const perPage = 25
  mockLocation(`http://example.com?page=${page}&per_page=${perPage}`)

  const wrapper = mountWrapper({ itemCount })
  const pagination = wrapper.find('.pf-c-pagination').first()

  pagination.find('button[data-action="first"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="previous"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="next"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))

  pagination.find('button[data-action="last"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))
})

it('should be able to jump to a page', () => {
  const itemCount = 100
  mockLocation('http://example.com')

  const wrapper = mountWrapper({ itemCount })
  const pagination = wrapper.find('.pf-c-pagination').first()

  const nextPage = 2
  const input = pagination.find('.pf-c-pagination__nav-page-select input')
  input.simulate('change', { target: { value: nextPage } })
  input.simulate('keydown', { key: 'Enter' })
  expect(window.location.replace).toHaveBeenCalledWith(`http://example.com/?page=${nextPage}`)
})
