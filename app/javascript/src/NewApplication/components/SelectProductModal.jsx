// @flow

import React, { useState } from 'react'

import {
  Button,
  Modal,
  InputGroup,
  TextInput,
  Pagination,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import { Table, TableHeader, TableBody } from '@patternfly/react-table'
import SearchIcon from '@patternfly/react-icons/dist/js/icons/search-icon'

import type { Product } from 'NewApplication/types'

import './SelectModal.scss'

type Props = {
  isOpen?: boolean,
  product: Product | null,
  products: Product[],
  onSelectProduct: (Product) => void,
  onClose: () => void
}

const PER_PAGE = 5

const SelectProductModal = ({ isOpen, product, products, onSelectProduct, onClose }: Props) => {
  // FIXME: selected product in the Modal should coincide with the one selected in the Select
  const [selectedProductId, setSelectedProductId] = useState<number>(product ? product.id : -1)
  const [page, setPage] = useState<number>(1)

  const handleOnSelect = (_e, _i, rowId) => {
    const selectedProduct = pageProducts.find((p, i) => i === selectedProductId)
    setSelectedProductId(selectedProduct ? selectedProduct.id : -1)
  }

  const columns = [
    { title: 'Name' },
    { title: 'System Name' },
    { title: 'Last updated' }
  ]

  const pagination = (
    <Pagination
      perPage={PER_PAGE}
      itemCount={products.length}
      page={page}
      onSetPage={(_e, page) => setPage(page)}
      widgetId="pagination-options-menu-top"
    />
  )

  const pageProducts = products.slice((page - 1) * PER_PAGE, page * PER_PAGE)

  const rows = pageProducts.map(p => ({
    selected: p.id === selectedProductId,
    cells: [p.name, p.systemName, p.updatedAt]
  }))

  const onAccept = () => {
    const product = products.find(p => p.id === selectedProductId)
    if (product) {
      onSelectProduct(product)
    }
  }

  return (
    <Modal
      title='Select a Product'
      isLarge={true}
      isOpen={isOpen}
      onClose={onClose}
      isFooterLeftAligned={true}
      actions={[
        <Button key='add' variant='primary' isDisabled={selectedProductId === -1} onClick={onAccept}>Add</Button>,
        <Button key='cancel' variant='secondary' onClick={onClose}>Cancel</Button>
      ]}
    >
      {/* Toolbar is a component in the css, but a layout in react, so the class names are mismatched (pf-c-toolbar vs pf-l-toolbar) Styling doesn't work, but if you change it to pf-c in the inspector, it works */}
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <InputGroup>
            <TextInput name="searchInput" id="searchInput" type="search" aria-label="search for a product" />
            <Button variant="control" aria-label="search button for search input">
              <SearchIcon />
            </Button>
          </InputGroup>
        </ToolbarItem>
        <ToolbarItem>
          {pagination}
        </ToolbarItem>
      </Toolbar>
      <Table
        aria-label="Products"
        sortBy={() => {}}
        onSort={() => {}}
        onSelect={handleOnSelect}
        cells={columns}
        rows={rows}
        selectVariant='radio'
      >
        <TableHeader />
        <TableBody />
      </Table>
      {pagination}
    </Modal>
  )
}

export { SelectProductModal }
