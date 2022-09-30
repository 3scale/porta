import { mount } from 'enzyme'

import { IndexPage, Props } from 'BackendApis/components/IndexPage'
import { mockLocation } from 'utilities/test-utils'
import { Backend } from 'BackendApis/types'

const defaultProps = {
  newBackendPath: '',
  backends: [],
  backendsCount: 0
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a link to the New Product page', () => {
  const newBackendPath = 'services/new'
  const wrapper = mountWrapper({ newBackendPath })
  expect(wrapper.find(`a[href="${newBackendPath}"]`).exists()).toBe(true)
})

it('should render a table with backends', () => {
  const backends: Backend[] = new Array(10).fill({}).map((i, j) => ({
    id: j,
    name: `Backend API ${j}`,
    systemName: `backend_api_${j}`,
    updatedAt: '',
    privateEndpoint: '',
    links: [{ name: 'Edit', path: '' }, { name: 'Overview', path: '' }, { name: 'Analytics', path: '' }, { name: 'Methods and Metrics', path: '' }, { name: 'Mapping Rules', path: '' }],
    productsCount: 0
  }))
  const backendsCount = backends.length
  const wrapper = mountWrapper({ backends, backendsCount })
  expect(wrapper.find('tbody tr')).toHaveLength(backendsCount)
})

it('should have a paginated table', () => {
  const backendsCount = 10
  mockLocation(`href://foo.bar/metrics?per_page=2&page=2`)
  const wrapper = mountWrapper({ backendsCount })
  const pagination = wrapper.find('.pf-c-pagination').first()

  expect(pagination.find('[aria-label="Current page"]').first().prop('value')).toBe(2)

  pagination.find('button[data-action="first"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="previous"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="next"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))

  pagination.find('button[data-action="last"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))

  expect(pagination.find('.pf-c-options-menu__toggle-text').text()).toMatch(`3 - 4 of ${backendsCount}`)
})
