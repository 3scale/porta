import { useRef, useState } from 'react'

import { CompactListCard } from 'Common/components/CompactListCard'
import { useSearchInputEffect } from 'utilities/useSearchInputEffect'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { CompactListItem } from 'Common/components/CompactListCard'

interface Props {
  products: CompactListItem[];
}

const ProductsUsedListCard: React.FunctionComponent<Props> = ({ products }) => {
  const [page, setPage] = useState(1)
  const [filteredProducts, setFilteredProducts] = useState(products)
  const searchInputRef = useRef<HTMLInputElement | null>(null)

  const handleOnSearch = (term = '') => {
    setFilteredProducts(products.filter(p => {
      const regex = new RegExp(term, 'i')
      return regex.test(p.name)
    }))
    setPage(1)
  }

  useSearchInputEffect(searchInputRef, handleOnSearch)

  return (
    <CompactListCard
      columns={['Name', 'System Name']}
      items={filteredProducts}
      page={page}
      searchInputPlaceholder="Find a product"
      searchInputRef={searchInputRef}
      setPage={setPage}
      tableAriaLabel="Products using this backend"
      onSearch={handleOnSearch}
    />
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ProductsUsedListCardWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ProductsUsedListCard {...props} />, containerId) }

export { ProductsUsedListCard, ProductsUsedListCardWrapper, Props }
