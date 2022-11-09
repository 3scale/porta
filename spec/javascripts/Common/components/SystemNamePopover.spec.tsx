import { mount } from 'enzyme'

import { SystemNamePopover } from 'Common/components/SystemNamePopover'

const mountWrapper = () => mount(<SystemNamePopover />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(SystemNamePopover)).toEqual(true)
})
