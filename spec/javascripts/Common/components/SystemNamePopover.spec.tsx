import React from 'react'
import { mount } from 'enzyme'

import { SystemNamePopover } from 'Common/components/SystemNamePopover'

const mountWrapper = () => mount(<SystemNamePopover />)

afterEach(() => jest.resetAllMocks())

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists(SystemNamePopover)).toBe(true)
})
