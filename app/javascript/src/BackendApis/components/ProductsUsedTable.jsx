// @flow

import * as React from 'react'
import { useState, useRef } from 'react'

import {
  Button,
  ButtonVariant,
  InputGroup,
  TextInput,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { Table, TableBody } from '@patternfly/react-table'
import { SearchIcon } from '@patternfly/react-icons'
import { MicroPagination } from 'Common'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { useSearchInputEffect } from 'utilities/custom-hooks'

import './ProductsUsedTable.scss'

import type { Product } from 'Types'

type Props = {
  products: Array<Product>
}

const PER_PAGE = 5

const ProductsUsedTable = ({ products }: Props): React.Node => {
  const [page, setPage] = useState(1)
  const [filteredProducts, setFilteredProducts] = useState(products)
  const searchInputRef = useRef(null)

  const search = (term: string = '') => {
    setFilteredProducts(products.filter(p => p.name.includes(term)))
    setPage(1)
  }

  useSearchInputEffect(searchInputRef, search)

  const handleOnSearch = () => {
    if (searchInputRef.current) {
      search(searchInputRef.current.value)
    }
  }

  const handleOnTextInputKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleOnSearch()
    }
  }

  const lastPage = Math.ceil(filteredProducts.length / PER_PAGE)
  const pageItems = filteredProducts.slice((page - 1) * PER_PAGE, page * PER_PAGE)
  const columns = ['Name', 'System name']
  const rows = pageItems.map(p => ({
    cells: [
      { title: <Button href={p.path} component="a" variant="link" isInline>{p.name}</Button> },
      p.systemName
    ]
  }))

  const header = (
    <InputGroup>
      <TextInput
        type="search"
        aria-label="search for an item"
        ref={searchInputRef}
        onKeyDown={handleOnTextInputKeyDown}
        placeholder="Find a Product"
      />
      <Button variant={ButtonVariant.control} aria-label="search button for search input" onClick={handleOnSearch} data-testid="search">
        <SearchIcon />
      </Button>
    </InputGroup>
  )

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Table
        header={header}
        aria-label="Products used by this backend"
        cells={columns}
        rows={rows}
      >
        <TableBody />
      </Table>
      <MicroPagination page={page} setPage={setPage} lastPage={lastPage} />
    </PageSection>
  )
}

const ProductsUsedTableWrapper = (props: Props, containerId: string): void => createReactWrapper(<ProductsUsedTable {...props} />, containerId)

export { ProductsUsedTable, ProductsUsedTableWrapper }
