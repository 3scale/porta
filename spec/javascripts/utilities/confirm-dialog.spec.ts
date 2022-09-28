import { confirm } from 'utilities/confirm-dialog'

const confirmSpy = jest.spyOn(window, 'confirm')

it('should work', async () => {
  const msg = 'Please confirm'
  confirmSpy.mockReturnValue(true)

  const confirmed = await confirm(msg)

  expect(confirmSpy).toHaveBeenCalledWith(msg)
  expect(confirmed).toEqual(true)
})
