import { mount } from 'enzyme'

import { ListItem } from 'PaymentGateways/braintree/components/ListItem'

import type { Props } from 'PaymentGateways/braintree/components/ListItem'

const Child = () => {
  return <p id="child">Hi</p>
}

const props: Props = {
  id: 'my-unique-id',
  children: null
}

it('should render properly', () => {
  const wrapper = mount(<ListItem {...props} />)
  expect(wrapper.exists()).toEqual(true)
})

it('should render without children', () => {
  const wrapper = mount(<ListItem {...props} />)
  expect(wrapper.exists('#child')).toEqual(false)
})

it('should render children', () => {
  const wrapper = mount(
    <ListItem id="my-unique-id">
      <Child />
    </ListItem>
  )
  expect(wrapper.exists('#child')).toEqual(true)
})
