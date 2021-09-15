// @flow

import * as React from 'react'

import { sortable } from '@patternfly/react-table'
import { fetchPaginatedProducts } from 'NewApplication'
import { SelectWithModal } from 'Common'

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
  <SelectWithModal
    label="Product"
    fieldId="account_id"
    id="product"
    name=""
    item={product}
    items={mostRecentlyUpdatedProducts}
    itemsCount={productsCount}
    cells={cells}
    onSelect={onSelectProduct}
    fetchItems={(params) => fetchPaginatedProducts(productsPath, params)}
    onAbortFetch={() => console.log('abort')}
    header="Most recently updated Products"
    isDisabled={isDisabled}
    title="Select a Product"
    placeholder="Select a Product"
    footerLabel="View all Products"
  />
)

export { ProductSelect }
