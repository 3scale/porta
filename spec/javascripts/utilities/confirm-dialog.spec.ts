import { waitConfirm } from 'utilities/confirm-dialog'

const confirmSpy = jest.spyOn(window, 'confirm')

it('should work', async () => {
  const msg = 'Please confirm'
  confirmSpy.mockReturnValue(true)

  const confirmed = await waitConfirm(msg)

  expect(confirmSpy).toHaveBeenCalledWith(msg)
  expect(confirmed).toEqual(true)
})
