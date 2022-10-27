import * as React from 'react'
import { useState, useRef } from 'react'

import { CompactListCard, CompactListItem } from 'Common'
import { createReactWrapper, useSearchInputEffect } from 'utilities'

type Props = {
  products: Array<CompactListItem>
};

const ProductsUsedListCard = (
  {
    products
  }: Props
): React.ReactElement => {
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
      searchInputRef={searchInputRef}
      onSearch={handleOnSearch}
      page={page}
      setPage={setPage}
      searchInputPlaceholder="Find a product"
      tableAriaLabel="Products using this backend"
    />
  )
}

const ProductsUsedListCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductsUsedListCard {...props} />, containerId)

export { ProductsUsedListCard, ProductsUsedListCardWrapper, Props }
