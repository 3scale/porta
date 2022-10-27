import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'

const container = document.createElement('div')
jest.spyOn(document, 'getElementById')
  .mockImplementationOnce(() => container)

const TestComponent: FunctionComponent = () => <div>Hello!</div>

it('should work', () => {
  createReactWrapper(<TestComponent />, 'container_id')
  expect(container.innerHTML).toEqual('<div>Hello!</div>')
})
