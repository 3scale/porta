import { mount } from 'enzyme'

import { ProductsWidget, Props } from 'Dashboard/components/ProductsWidget'

const defaultProps = {
  newProductPath: '',
  productsPath: '',
  products: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ProductsWidget {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
