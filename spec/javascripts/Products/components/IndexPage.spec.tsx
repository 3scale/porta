import { mount } from 'enzyme'

import { IndexPage } from 'Products/components/IndexPage'

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
  expect(wrapper.exists()).toEqual(true)
})

it('should have a link to the New Product page', () => {
  const newProductPath = 'services/new'
  const wrapper = mountWrapper({ newProductPath })
  expect(wrapper.exists(`a[href="${newProductPath}"]`)).toEqual(true)
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
  const wrapper = mountWrapper({ productsCount })
  const pagination = wrapper.find('.pf-c-pagination').first()

  expect(pagination.find('[aria-label="Current page"]').first().prop('value')).toBe(2)
})
