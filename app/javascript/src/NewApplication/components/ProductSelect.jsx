// @flow

import React from 'react'

import { SelectWithModal } from 'Common'

import type { Product } from 'NewApplication/types'

type Props = {
  product: Product | null,
  products: Product[],
  onSelectProduct: (Product | null) => void,
  isDisabled?: boolean
}

const ProductSelect = ({ product, products, onSelectProduct, isDisabled }: Props) => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <SelectWithModal
      label="Product"
      // Do not submit
      // fieldId="TODO"
      id="product"
      // name="TODO"

      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      item={product}
      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      items={products.map(p => ({ ...p, description: p.systemName }))}
      cells={cells}
      modalTitle="Select an Account"
      onSelect={onSelectProduct}
      header="Most recently created Accounts"
      footer="View all Accounts"
      isDisabled={isDisabled}
    />
  )
}
export { ProductSelect }
