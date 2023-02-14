module.exports = {
  client: {
    create: () => Promise.resolve({})
  },
  hostedFields: {
    create: () => Promise.resolve({
      getState: () => ({ fields: {} }),
      on: (event, cb) => {
        if (event === 'validityChange') { cb() }
        if (event === 'lookup-complete') { /* do nothing? */ }
      },
      tokenize: () => Promise.resolve({
        details: {
          bin: 'bin'
        },
        nonce: 'This is non-cense'
      })
    })
  },
  threeDSecure: {
    create: () => Promise.resolve({
      on: jest.fn(),
      verifyCard: (_, cb) => {
        cb(undefined, {
          nonce: 'This is a 3DS verified transaction'
        })
      }
    })
  },
}
