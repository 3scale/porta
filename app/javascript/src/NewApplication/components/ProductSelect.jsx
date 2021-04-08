// @flow

import * as React from 'react'

import { SelectWithModal } from 'Common'

import type { Product } from 'NewApplication/types'

type Props = {
  product: Product | null,
  products: Product[],
  onSelectProduct: (Product | null) => void,
  isDisabled?: boolean
}

const ProductSelect = ({ product, products, onSelectProduct, isDisabled }: Props): React.Node => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <SelectWithModal
      label="Product"
      id="product"
      // $FlowIgnore[incompatible-type] Product implements Record
      item={product}
      items={products.map(p => ({ ...p, description: p.systemName }))}
      cells={cells}
      modalTitle="Select an Account"
      // $FlowIssue[incompatible-type] It should not complain since Record.id has union "number | string"
      onSelect={onSelectProduct}
      header="Most recently created Accounts"
      footer="View all Accounts"
      isDisabled={isDisabled}
    />
  )
}
export { ProductSelect }
