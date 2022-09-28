import { fetchData } from 'utilities/fetchData'

const fetch = jest.fn()
global.fetch = fetch

it('should fetch some data', async () => {
  const data = { foo: 'bar' }
  fetch.mockResolvedValue({
    ok: true,
    json: () => Promise.resolve(data)
  })

  expect(await fetchData('url')).toEqual(data)
})

it('should throw an error if request is not ok', async () => {
  const statusText = '500 Bad Request'
  fetch.mockResolvedValue({
    ok: false,
    statusText
  })

  await expect(fetchData('url')).rejects.toThrow(statusText)
})
