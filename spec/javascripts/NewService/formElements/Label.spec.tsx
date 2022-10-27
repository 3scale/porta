import { mount } from 'enzyme'

import { Label } from 'NewService/components/FormElements/Label'

const props = {
  htmlFor: 'label',
  label: 'My Label',
  required: true
}

it('should render itself properly', () => {
  const wrapper = mount(<Label {...props} />)
  expect(wrapper.find('label').props().htmlFor).toEqual('label')
  expect(wrapper.find('label').text()).toContain('My Label*')
  expect(wrapper.find('abbr').exists()).toEqual(true)
})

it('should not render <abbr> tag when not required', () => {
  const propsNotRequired = { ...props, required: false }
  const wrapper = mount(<Label {...propsNotRequired} />)
  expect(wrapper.find('abbr').exists()).toEqual(false)
})
