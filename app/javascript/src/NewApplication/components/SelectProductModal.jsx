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
  const columns = [
    { title: 'Name' },
    { title: 'System Name' },
    { title: 'Last updated' }
  ]

  const cells = ['name', 'systemName', 'updatedAt']

  return (
    <SelectModal
      title="Select a Product"
      isOpen={isOpen}
      item={product}
      items={products}
      onSelect={onSelectProduct}
      onClose={onClose}
      columns={columns}
      cells={cells}
    />
  )
}

export { SelectProductModal }
