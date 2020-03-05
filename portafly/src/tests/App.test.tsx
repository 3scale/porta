import React from 'react'
import { App } from 'App'
import { render } from 'tests/custom-render'

it('renders without crashing', () => {
  const wrapper = render(<App />)
  expect(wrapper).not.toBeNull()
})
