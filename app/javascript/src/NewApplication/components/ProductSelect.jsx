// @flow

import * as React from 'react'

import { sortable } from '@patternfly/react-table'
import { fetchPaginatedProducts } from 'NewApplication/data'
import { SelectWithModal } from 'Common'

import type { Product } from 'NewApplication/types'

type Props = {
  product: Product | null,
  products: Product[],
  productsCount: number,
  onSelectProduct: (Product | null) => void,
  productsPath?: string,
  isDisabled?: boolean
}

const ProductSelect = ({
  product,
  products,
  productsCount,
  onSelectProduct,
  productsPath = '',
  isDisabled
}: Props): React.Node => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt', transforms: [sortable] }
  ]

  return (
    // $FlowFixMe[prop-missing] description not needed for selected product
    // $FlowIssue[incompatible-type-arg] id can be string too
    <SelectWithModal
      label="Product"
      fieldId="product"
      id="product"
      name=""
      item={product}
      items={products.map(p => ({ ...p, description: p.systemName }))}
      itemsCount={productsCount}
      cells={cells}
      onSelect={onSelectProduct}
      fetchItems={(params) => fetchPaginatedProducts(productsPath, params)}
      header="Most recently updated Products"
      isDisabled={isDisabled}
      title="Select a Product"
      placeholder="Select a Product"
      footerLabel="View all Products"
    />
  )
}

export { ProductSelect }
