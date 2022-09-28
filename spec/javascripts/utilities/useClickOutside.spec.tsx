import React, { FunctionComponent } from 'react'
import { mount } from 'enzyme'

import { useClickOutside } from 'utilities/useClickOutside'

const HookedComponent: FunctionComponent<{ callback: jest.Mock}> = ({ callback }) => {
  const ref = React.useRef(null)
  useClickOutside(ref, callback)

  return <div ref={ref}>I am hooked</div>
}

it('should and and remove a mousedown event listener', () => {
  const addEventListener = jest.fn()
  const removeEventListener = jest.fn()

  document.addEventListener = addEventListener
  document.removeEventListener = removeEventListener

  const wrapper = mount(<HookedComponent callback={jest.fn()} />)
  expect(addEventListener).toHaveBeenCalledTimes(1)

  wrapper.unmount()
  expect(removeEventListener).toHaveBeenCalledTimes(1)
})

it.skip('should call the callback when clicked outside', async () => {
  const callback = jest.fn()

  const wrapper = mount(
    <div id="container">
      <HookedComponent callback={callback} />
      <span>TODO: Click here and expect callback to be called</span>
    </div>
  )
})
