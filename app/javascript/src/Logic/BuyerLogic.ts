import type { Buyer, Product, ServicePlan } from 'NewApplication/types'

class BuyerLogic {
  buyer: Buyer;

  constructor (buyer: Buyer) {
    this.buyer = buyer
  }

  getContractedServicePlan (product: Product): ServicePlan | null {
    const contract = this.buyer.contractedProducts.find(p => p.id === product.id)
    return (contract && contract.withPlan) || null
  }

  isSubscribedTo (product: Product): boolean {
    return this.buyer.contractedProducts.some(p => p.id === product.id)
  }
}

export { BuyerLogic }
