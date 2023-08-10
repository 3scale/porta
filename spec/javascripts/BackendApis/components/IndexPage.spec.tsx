import { mount } from 'enzyme'

import { IndexPage } from 'BackendApis/components/IndexPage'

import type { Props } from 'BackendApis/components/IndexPage'
import type { Backend } from 'BackendApis/types'

const defaultProps = {
  newBackendPath: '',
  backends: [],
  backendsCount: 0
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should have a link to the New Product page', () => {
  const newBackendPath = 'services/new'
  const wrapper = mountWrapper({ newBackendPath })
  expect(wrapper.exists(`a[href="${newBackendPath}"]`)).toEqual(true)
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
  const wrapper = mountWrapper({ backendsCount })
  expect(wrapper.find('.pf-c-pagination').exists()).toEqual(true)
})
