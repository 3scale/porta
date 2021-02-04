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

import './SelectProductModal.scss'

type Props = {
  isOpen?: boolean,
  products: Product[],
  onSelectProduct: (Product) => void,
  onClose: () => void
}

const SelectProductModal = ({ isOpen, products, onSelectProduct, onClose }: Props) => {
  const [selectedRowId, setSelectedRowId] = useState<number>(-1)
  const modalColumns = [
    { title: 'Name' },
    { title: 'System Name' },
    { title: 'Last updated' }
  ]
  const modalRows = products.map((p, i) => ({
    selected: i === selectedRowId,
    cells: [p.name, p.systemName, p.updatedAt]
  }))

  const onAccept = () => {
    onSelectProduct(products[selectedRowId])
  }

  const pagination = (
    <Pagination
      itemCount={products.length}
      // perPage={this.state.perPage}
      // page={this.state.page}
      // onSetPage={this.onSetPage}
      // widgetId="pagination-options-menu-top"
      // onPerPageSelect={this.onPerPageSelect}
    />
  )

  return (
    <Modal
      title='Select a Product'
      isLarge={true}
      isOpen={isOpen}
      onClose={onClose}
      isFooterLeftAligned={true}
      actions={[
        <Button key='add' variant='primary' isDisabled={selectedRowId === -1} onClick={onAccept}>Add</Button>,
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
        sortBy={() => {}}
        onSort={() => {}}
        onSelect={(_e, _i, rowId) => setSelectedRowId(rowId)}
        cells={modalColumns}
        rows={modalRows}
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
