import { mount } from 'enzyme'

import { BuyerSelect } from 'NewApplication/components/BuyerSelect'

import type { Props } from 'NewApplication/components/BuyerSelect'

const buyer = {
  id: 0,
  name: 'The Buyer',
  admin: 'The Admin',
  contractedProducts: [],
  createApplicationPath: '',
  createdAt: '',
  multipleAppsAllowed: false
}
const buyers = [buyer]
const props: Props = {
  buyer,
  buyers,
  buyersCount: buyers.length,
  onSelectBuyer: jest.fn(),
  buyersPath: '/buyers',
  isDisabled: false
}

it('should render', () => {
  const wrapper = mount(<BuyerSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
