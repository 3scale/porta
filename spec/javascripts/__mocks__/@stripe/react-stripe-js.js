const confirmCardSetup = jest.fn()

const Elements = () => null

const CardElement = () => null

const useStripe = () => ({
  confirmCardSetup
})

const useElements = () => ({
  getElement: jest.fn()
})

export { Elements, CardElement, useStripe, useElements }
