import { error, notice } from 'utilities/flash'

const noticeSpy = jest.spyOn(global.window.$.flash, 'notice')
const errorSpy = jest.spyOn(global.window.$.flash, 'error')

it('should not fail', () => {
  notice('foo')
  expect(noticeSpy).toHaveBeenCalledWith('foo')

  error('bar')
  expect(errorSpy).toHaveBeenCalledWith('bar')
})
