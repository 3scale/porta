// @flow

import type { Buyer, Product, ServicePlan } from 'NewApplication/types'

class BuyerLogic {
  buyer: Buyer

  constructor (buyer: Buyer) {
    this.buyer = buyer
  }

  getContractedServicePlan (product: Product): ServicePlan | null {
    const contract = this.buyer.contractedProducts.find(p => String(p.id) === product.id)
    return (contract && contract.withPlan) || (product && product.defaultServicePlan) || null
  }
}

export { BuyerLogic }
