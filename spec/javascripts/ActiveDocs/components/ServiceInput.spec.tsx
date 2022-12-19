import { mount } from 'enzyme'

import { ServiceSelect } from 'ActiveDocs/components/ServiceSelect'

const mountWrapper = () => mount(<ServiceSelect service={{ id: 1, name: 'Pepe' }} services={[]} setService={jest.fn()} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})
