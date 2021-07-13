// @flow

import * as React from 'react'

import { sortable } from '@patternfly/react-table'
import { fetchPaginatedProducts } from 'NewApplication'
import { SelectWithPaginatedModal } from 'Common'

import type { Product } from 'NewApplication/types'

type Props = {
  product: Product | null,
  mostRecentlyUpdatedProducts: Product[],
  productsCount: number,
  onSelectProduct: (Product | null) => void,
  productsPath: string,
  isDisabled?: boolean
}

const cells = [
  { title: 'Name', propName: 'name' },
  { title: 'System Name', propName: 'systemName' },
  { title: 'Last updated', propName: 'updatedAt', transforms: [sortable] }
]

const ProductSelect = ({
  product,
  mostRecentlyUpdatedProducts,
  productsCount,
  onSelectProduct,
  productsPath,
  isDisabled
}: Props): React.Node => (
  // $FlowIssue[incompatible-type-arg] id can be string too
  <SelectWithPaginatedModal
    label="Product"
    fieldId="account_id"
    id="product"
    name=""
    item={product}
    items={mostRecentlyUpdatedProducts}
    itemsCount={productsCount}
    onSelect={onSelectProduct}
    cells={cells}
    onSelect={onSelectProduct}
    fetchItems={(params) => fetchPaginatedProducts(productsPath, params)}
    header="Most recently updated Products"
    title="Select a Product"
    isDisabled={isDisabled}
    placeholder="Select a Product"
    footerLabel="View all Products"
    isDisabled={isDisabled}
    cells={cells}
  />
)

export { ProductSelect }
