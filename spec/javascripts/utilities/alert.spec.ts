import { error, notice } from 'utilities/alert'

const noticeSpy = jest.spyOn((global as any).$.flash, 'notice')
const errorSpy = jest.spyOn((global as any).$.flash, 'error')

it('should not fail', () => {
  notice('foo')
  expect(noticeSpy).toHaveBeenCalledWith('foo')

  error('bar')
  expect(errorSpy).toHaveBeenCalledWith('bar')
})
