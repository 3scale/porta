import { mount } from 'enzyme'

import { ServiceInput } from 'ActiveDocs/components/ServiceSelect'

const mountWrapper = () => mount(<ServiceInput service="" setService={jest.fn()} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})
