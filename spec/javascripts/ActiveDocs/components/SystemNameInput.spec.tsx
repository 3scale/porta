import { mount } from 'enzyme'

import { SystemNameInput } from 'ActiveDocs/components/SystemNameInput'

const mountWrapper = () => mount(<SystemNameInput setSystemName={jest.fn()} systemName="" />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})
