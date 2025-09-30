import { randomUUID } from 'crypto'

import type { Product } from 'SiteEmails/types'

/**
 * Generates a new Product with a UUID as id. Props can be overridden by passing an object.
 * @param props An object containing props to override the factory defaults
 */
function productFactory (props?: Partial<Product>): Product

/**
 * Generates an array of Products, with UUID as ids.
 * @param input The length of the array
 */
function productFactory (input: number): Product[]

function productFactory (input?: Partial<Product> | number): Product | Product[] {
  if (typeof input === 'number') {
    return new Array(input).fill(undefined).map(() => productFactory())

  } else {
    const id = input?.id ?? randomUUID()
    return {
      // @ts-expect-error Rails uses number for ids, but it's OK to use string.
      id,
      name: `Product ${id}`,
      systemName: `product_${id}`,
      updatedAt: '2023-01-01',
      ...(input ?? {})
    }
  }
}

function exceptionFactory (props?: Partial<Product>): Product
function exceptionFactory (input: number): Product[]
function exceptionFactory (input?: Partial<Product> | number): Product | Product[] {
  if (typeof input === 'number') {
    return new Array(input).fill(undefined).map(() => exceptionFactory())

  } else {
    const product = productFactory(input)
    return { supportEmail: `support-${product.id}@example.org`, ...product }
  }
}

export { productFactory, exceptionFactory }
