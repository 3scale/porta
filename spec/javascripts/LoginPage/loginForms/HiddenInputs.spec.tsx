import { shallow } from 'enzyme'

import { HiddenInputs } from 'LoginPage'

it('should render itself', () => {
  const wrapper = shallow(<HiddenInputs />)
  expect(wrapper.exists()).toBe(true)
})

it('should render 1 input hidden fields when password reset is false', () => {
  const wrapper = shallow(<HiddenInputs isPasswordReset={false} />)

  expect(wrapper.find('input').length).toEqual(1)
  expect(wrapper.find('CSRFToken').length).toEqual(1)
})

it('should render 2 input hidden fields when password reset is true', () => {
  const wrapper = shallow(<HiddenInputs isPasswordReset />)

  expect(wrapper.find('input').length).toEqual(2)
  expect(wrapper.find('CSRFToken').length).toEqual(1)
})
