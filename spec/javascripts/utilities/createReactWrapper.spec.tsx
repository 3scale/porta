
import { createReactWrapper } from 'utilities/createReactWrapper'

const container = document.createElement('div')
jest.spyOn(document, 'getElementById')
  .mockImplementationOnce(() => container)

const TestComponent = () => <div>Hello!</div>

it('should work', () => {
  createReactWrapper(<TestComponent />, 'container_id')
  expect(container.innerHTML).toEqual('<div>Hello!</div>')
})
