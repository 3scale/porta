import { mount } from 'enzyme'
import { Input } from 'PaymentGateways/braintree/components/Input'

import type { Props } from 'PaymentGateways/braintree/components/Input'

const onChangeSPy = jest.fn()
const props: Props = {
  id: 'my-id',
  required: true,
  name: 'username',
  value: 'Shaquille O Neal',
  onChange: onChangeSPy
}

it('should render properly', () => {
  const wrapper = mount(<Input {...props} />)
  expect(wrapper.exists()).toBe(true)
})

it('should render with right props', () => {
  const wrapper = mount(<Input {...props} />)
  expect(wrapper.props().id).toEqual('my-id')
  expect(wrapper.props().required).toEqual(true)
  expect(wrapper.props().name).toEqual('username')
  expect(wrapper.props().value).toEqual('Shaquille O Neal')
})

it('should call onChange method', () => {
  const event = { currentTarget: { value: 'Magic Johnson' } }
  const wrapper = mount(<Input {...props} />)
  wrapper.props().onChange(event)
  expect(onChangeSPy).toHaveBeenCalledWith(event)
})
