import { mount } from 'enzyme'

import type { Props } from 'utilities/ReCaptchaV3'
import type { FunctionComponent } from 'react'

const ReCaptchaV3 = jest.requireActual('utilities/ReCaptchaV3').ReCaptchaV3 as FunctionComponent<Props>

it('should render the ReCaptcha input', () => {
  const wrapper = mount(<ReCaptchaV3 action="test/action" siteKey="fakeKey" />)

  expect(wrapper.exists(ReCaptchaV3)).toEqual(true)
  expect(wrapper.find('input').prop('className')).toMatch('g-recaptcha')
})

it('should give the proper name to the input', () => {
  const action = 'test/action'
  const wrapper = mount(<ReCaptchaV3 action={action} siteKey="fakeKey" />)

  expect(wrapper.find('input').prop('name')).toBe(`g-recaptcha-response-data[${action}]`)
})
