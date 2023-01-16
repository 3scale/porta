import { BuyerLogic } from 'Logic/BuyerLogic'

import type { Buyer, Product, Plan } from 'NewApplication/types'

const buyer: Buyer = {
  id: 0,
  name: 'Mr. Buyer',
  admin: 'The Admin',
  createApplicationPath: '',
  createdAt: '',
  contractedProducts: [],
  multipleAppsAllowed: false
}
const plan: Plan = { id: 10, name: 'The Plan' } as Plan
const product: Product = { id: 1, name: 'The Product' } as Product

describe('getContractedServicePlan', () => {
  it('should return the contracted product', () => {
    const logic = new BuyerLogic({ ...buyer, contractedProducts: [{ id: 1, name: 'The Product', withPlan: plan }] })

    expect(logic.getContractedServicePlan(product)).toEqual(plan)
  })

  it('should return null when no contracted products', () => {
    const logic = new BuyerLogic({ ...buyer, contractedProducts: [] })

    expect(logic.getContractedServicePlan(product)).toEqual(null)
  })

  it('should return null when product is not contracted', () => {
    const logic = new BuyerLogic({ ...buyer, contractedProducts: [{ id: 999, name: 'The Other product', withPlan: plan }] })

    expect(logic.getContractedServicePlan(product)).toEqual(null)
  })

  it('should return null when no product contracted with a different plan', () => {
    const logic = new BuyerLogic({ ...buyer, contractedProducts: [{ id: 999, name: 'The Other product', withPlan: { id: 50, name: 'The Other Plan' } }] })

    expect(logic.getContractedServicePlan(product)).toEqual(null)
  })
})
