import { mount } from 'enzyme'

import { ProductsWidget } from 'Dashboard/components/ProductsWidget'

import type { Props } from 'Dashboard/components/ProductsWidget'

const defaultProps = {
  newProductPath: '',
  productsPath: '',
  products: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ProductsWidget {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
