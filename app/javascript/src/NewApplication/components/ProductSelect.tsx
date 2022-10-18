import { sortable } from '@patternfly/react-table'
import { fetchPaginatedProducts } from 'NewApplication/data/Products'
import { SelectWithModal } from 'Common/components/SelectWithModal'

import type { Props as SelectWithModalProps } from 'Common/components/SelectWithModal'
import type { Product } from 'NewApplication/types'

type Props = {
  product: Product | null,
  products: Product[],
  productsCount: number,
  onSelectProduct: (product: Product | null) => void,
  productsPath?: string,
  isDisabled?: boolean
}

const ProductSelect: React.FunctionComponent<Props> = ({
  product,
  products,
  productsCount,
  onSelectProduct,
  productsPath = '',
  isDisabled
}) => {
  const cells: SelectWithModalProps<Product>['cells'] = [
    { title: 'Name', propName: 'name' },
    { title: 'System Name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt', transforms: [sortable] }
  ]

  return (
    <SelectWithModal
      cells={cells}
      fetchItems={(params) => fetchPaginatedProducts(productsPath, params)}
      footerLabel="View all products"
      header="Recently updated products"
      id="product"
      isDisabled={isDisabled}
      item={product}
      items={products.map(p => ({ ...p, description: p.systemName }))}
      itemsCount={productsCount}
      label="Product"
      name=""
      placeholder="Select a product"
      searchPlaceholder="Find a product"
      title="Select a product"
      onSelect={onSelectProduct}
    />
  )
}

export { ProductSelect, Props }
