import { mount } from 'enzyme'

import { ApiJsonSpecInput } from 'ActiveDocs/components/ApiJsonSpecInput'

const mountWrapper = () => mount(<ApiJsonSpecInput apiJsonSpec="" setApiJsonSpec={jest.fn()} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})
