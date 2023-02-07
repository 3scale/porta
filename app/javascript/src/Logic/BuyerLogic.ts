import type { Buyer, Product, Plan } from 'NewApplication/types'

class BuyerLogic {
  public constructor (private readonly buyer: Buyer) {}

  public getContractedServicePlan (product: Product): Plan | null {
    const contract = this.buyer.contractedProducts.find(p => p.id === product.id)
    return contract?.withPlan ?? null
  }

  public isSubscribedTo (product: Product): boolean {
    return this.buyer.contractedProducts.some(p => p.id === product.id)
  }
}

export { BuyerLogic }
