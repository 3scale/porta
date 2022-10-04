import { mount } from 'enzyme'
import { IndexPage } from 'Products/components/IndexPage'
import { mockLocation } from 'utilities/test-utils'

import type { Props } from 'Products/components/IndexPage'
import type { Product } from 'Products/types'

const defaultProps: Props = {
  newProductPath: '',
  products: [],
  productsCount: 0
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a link to the New Product page', () => {
  const newProductPath = 'services/new'
  const wrapper = mountWrapper({ newProductPath })
  expect(wrapper.find(`a[href="${newProductPath}"]`).exists()).toBe(true)
})

it('should render a table with products', () => {
  const products: Product[] = new Array(10).fill({}).map((i, j) => ({
    id: j,
    name: `API ${j}`,
    systemName: `api_${j}`,
    updatedAt: '',
    links: [{ name: 'Edit', path: '' }, { name: 'Overview', path: '' }, { name: 'Analytics', path: '' }, { name: 'Applications', path: '' }, { name: 'ActiveDocs', path: '' }, { name: 'Integration', path: '' }],
    appsCount: 0,
    backendsCount: 0,
    unreadAlertsCount: 0
  }))
  const productsCount = products.length
  const wrapper = mountWrapper({ products, productsCount })
  expect(wrapper.find('tbody tr')).toHaveLength(productsCount)
})

it('should have a paginated table', () => {
  const productsCount = 10
  mockLocation(`href://foo.bar/metrics?per_page=2&page=2`)
  const wrapper = mountWrapper({ productsCount })
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

  expect(pagination.find('.pf-c-options-menu__toggle-text').text()).toMatch(`3 - 4 of ${productsCount}`)
})
