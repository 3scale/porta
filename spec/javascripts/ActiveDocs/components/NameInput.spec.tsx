import { mount } from 'enzyme'

import { NameInput } from 'ActiveDocs/components/NameInput'

const mountWrapper = () => mount(<NameInput errors={['']} name="" setName={jest.fn()} />)

it('should render itself', () => {
  const wrapper = mountWrapper()

  expect(wrapper.exists()).toEqual(true)
})
