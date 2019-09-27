import { isPolicyChainChanged } from 'Policies/util'

const originalChain = [
  {
    uuid: '64f09fc1-d35a-0e1b-018c-409312861a7d',
    data: {
      allow_origin: '123'
    }
  }
]

it('should detect when chain did not changed', () => {
  const changed = isPolicyChainChanged(originalChain, originalChain)

  expect(changed).toBe(false)
})

it('should detect a change when a new policy is added', () => {
  const newChain = [...originalChain, {}]
  const changed = isPolicyChainChanged(newChain, originalChain)

  expect(changed).toBe(true)
})

it('should detect a change when a policy is updated', () => {
  const newChain = [
    {
      uuid: '64f09fc1-d35a-0e1b-018c-409312861a7d',
      data: {
        allow_origin: '123 123 123'
      }
    }
  ]
  const changed = isPolicyChainChanged(newChain, originalChain)

  expect(changed).toBe(true)
})
