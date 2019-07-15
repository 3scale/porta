export const mockValidate = jest.fn()

const mock = jest.fn().mockImplementation(() => {
  return {validate: mockValidate}
})

export default mock
