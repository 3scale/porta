import { fetchData } from 'utilities/fetchData'

const mockedFetch = jest.fn()
global.fetch = mockedFetch

it('should fetch some data', async () => {
  const data = { foo: 'bar' }
  mockedFetch.mockResolvedValue({
    ok: true,
    json: async () => Promise.resolve(data)
  })

  expect(await fetchData('url')).toEqual(data)
})

it('should throw an error if request is not ok', async () => {
  const statusText = '500 Bad Request'
  mockedFetch.mockResolvedValue({
    ok: false,
    statusText
  })

  await expect(fetchData('url')).rejects.toThrow(statusText)
})
