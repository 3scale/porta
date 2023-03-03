module.exports = {
  Elements: () => null,
  CardElement: () => null,
  useStripe: () => ({
    confirmCardSetup: jest.fn(),
  }),
  useElements: () => ({
    getElement: jest.fn()
  })
}
