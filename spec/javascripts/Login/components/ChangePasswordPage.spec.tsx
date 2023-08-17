import { mount } from 'enzyme'

import { ChangePasswordPage } from 'Login/components/ChangePasswordPage'

const defaultProps = {

}

const mountWrapper = () => mount(<ChangePasswordPage {...defaultProps} />)

it('should render', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
