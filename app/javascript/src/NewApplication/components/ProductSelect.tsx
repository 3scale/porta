
import { sortable } from '@patternfly/react-table'
import { fetchPaginatedProducts } from 'NewApplication/data'
import { SelectWithModal, Props as SelectWithModalProps } from 'Common/components/SelectWithModal'

import { Product } from 'NewApplication/types'

type Props = {
  product: Product | null,
  products: Product[],
  productsCount: number,
  onSelectProduct: (arg1: Product | null) => void,
  productsPath?: string,
  isDisabled?: boolean
};

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
      label="Product"
      id="product"
      name=""
      item={product}
      items={products.map(p => ({ ...p, description: p.systemName }))}
      itemsCount={productsCount}
      cells={cells}
      onSelect={onSelectProduct}
      fetchItems={(params) => fetchPaginatedProducts(productsPath, params)}
      header="Recently updated products"
      isDisabled={isDisabled}
      title="Select a product"
      placeholder="Select a product"
      searchPlaceholder="Find a product"
      footerLabel="View all products"
    />
  )
}

export { ProductSelect }
