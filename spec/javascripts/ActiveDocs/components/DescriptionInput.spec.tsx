import { mount } from 'enzyme'

import { DescriptionInput } from 'ActiveDocs/components/DescriptionInput'

const mountWrapper = () => mount(<DescriptionInput description="" setDescription={jest.fn()} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})
