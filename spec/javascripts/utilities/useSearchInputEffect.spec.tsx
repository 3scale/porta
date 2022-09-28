import React, { FunctionComponent } from 'react'
import { mount } from 'enzyme'

import { useSearchInputEffect } from 'utilities/useSearchInputEffect'

const HookedComponent: FunctionComponent<{ inputRef: any, onSearch: jest.Mock }> = (props) => {
  useSearchInputEffect(props.inputRef, props.onSearch)

  return <div>I'm Hooked!</div>
}

it('should add and remove event listeners', () => {
  const addEventListener = jest.fn()
  const removeEventListener = jest.fn()

  const inputRef = {
    current: {
      addEventListener,
      removeEventListener
    }
  }

  const wrapper = mount(<HookedComponent inputRef={inputRef} onSearch={jest.fn()} />)
  expect(addEventListener).toHaveBeenNthCalledWith(1, 'input', expect.any(Function))
  expect(addEventListener).toHaveBeenNthCalledWith(2, 'keydown', expect.any(Function))

  wrapper.unmount()
  expect(removeEventListener).toHaveBeenNthCalledWith(1, 'input', expect.any(Function))
  expect(removeEventListener).toHaveBeenNthCalledWith(2, 'keydown', expect.any(Function))
})

it('should do stuff', () => {
  let listenToClearButton: any
  let listenToKeyDown: any

  const inputRef = {
    current: {
      value: 'looking for something',
      addEventListener: (type: string, cb: any) => {
        if (type === 'input') {
          listenToClearButton = cb
        } else if (type === 'keydown') {
          listenToKeyDown = cb
        }
      },
      removeEventListener: jest.fn()
    }
  }

  const onSearch = jest.fn()

  mount(<HookedComponent inputRef={inputRef} onSearch={onSearch} />)

  // Simulate input events
  listenToClearButton!({ inputType: 'anything' })
  expect(onSearch).not.toHaveBeenCalled()

  listenToClearButton!({ inputType: undefined })
  expect(onSearch).toHaveBeenCalledWith()

  onSearch.mockClear()
  // Simulate keydown events
  listenToKeyDown!({ key: 'Not Enter' })
  expect(onSearch).not.toHaveBeenCalled()

  listenToKeyDown!({ key: 'Enter' })
  expect(onSearch).toHaveBeenCalledWith('looking for something')
})
