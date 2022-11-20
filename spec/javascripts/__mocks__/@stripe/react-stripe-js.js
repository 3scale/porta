import React from 'react'

module.exports = {
  useStripe: () => undefined,
  useElements: () => undefined,
  CardElement: ({ onChange }) => (
    <div>CardElement</div>
  ),
  Elements: ({ children }) => (
    <div>
      {children}
    </div>
  )
}
