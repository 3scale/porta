// @flow

import React from 'react'

import { SelectModal } from 'Common'

import type { Product } from 'NewApplication/types'

type Props = {
  isOpen?: boolean,
  product: Product | null,
  products: Product[],
  onSelectProduct: (Product) => void,
  onClose: () => void
}

const SelectProductModal = ({ isOpen, product, products, onSelectProduct, onClose }: Props) => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <SelectModal
      title="Select a Product"
      isOpen={isOpen}
      item={product}
      items={products}
      onSelect={onSelectProduct}
      onClose={onClose}
      cells={cells}
    />
  )
}

export { SelectProductModal }
