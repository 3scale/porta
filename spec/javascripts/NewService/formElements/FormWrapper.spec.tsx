import { mount, shallow } from 'enzyme'

import { FormWrapper } from 'NewService/components/FormElements/FormWrapper'
import { HiddenServiceDiscoveryInput } from 'NewService/components/FormElements/HiddenServiceDiscoveryInput'

const submitText = 'Add API'
const props = {
  id: 'form-id',
  formActionPath: 'my-path',
  hasHiddenServiceDiscoveryInput: true,
  submitText
}

it('should render itself', () => {
  const wrapper = shallow(<FormWrapper {...props} />)
  expect(wrapper.exists('#form-id')).toEqual(true)
})

it('should render an empty input', () => {
  const wrapper = shallow(<FormWrapper {...props} />)
  const input = wrapper.find('input[name="utf8"][type=\'hidden\']')
  expect(input.exists()).toEqual(true)
})

it('should render submit button with proper text', () => {
  const wrapper = mount(<FormWrapper {...props} />)
  const button = wrapper.find('button[type=\'submit\']')
  expect(button.exists()).toEqual(true)
  expect(button.text()).toEqual(submitText)
})

it('should render a hidden input for service discovery when required', () => {
  const wrapper = shallow(<FormWrapper {...props} />)

  wrapper.setProps({ hasHiddenServiceDiscoveryInput: false })
  expect(wrapper.exists(HiddenServiceDiscoveryInput)).toEqual(false)

  wrapper.setProps({ hasHiddenServiceDiscoveryInput: true })
  expect(wrapper.exists(HiddenServiceDiscoveryInput)).toEqual(true)
})

it('should render `CSRFToken` child', () => {
  const wrapper = shallow(<FormWrapper {...props} />)
  expect(wrapper.exists('CSRFToken')).toEqual(true)
})
