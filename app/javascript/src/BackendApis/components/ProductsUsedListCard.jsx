// @flow

import * as React from 'react'
import { useState, useRef } from 'react'

import { CompactListCard } from 'Common'
import { createReactWrapper, useSearchInputEffect } from 'utilities'

import type { CompactListItem } from 'Common'

type Props = {
  products: Array<CompactListItem>
}

const ProductsUsedListCard = ({ products }: Props): React.Node => {
  const [page, setPage] = useState(1)
  const [filteredProducts, setFilteredProducts] = useState(products)
  const searchInputRef = useRef<HTMLInputElement | null>(null)

  const handleOnSearch = (term: string = '') => {
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
      searchInputPlaceholder="Find a Product"
      tableAriaLabel="Products used by this backend"
    />
  )
}

const ProductsUsedListCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductsUsedListCard {...props} />, containerId)

export { ProductsUsedListCard, ProductsUsedListCardWrapper }
