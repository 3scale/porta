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

import type { Buyer } from 'NewApplication/types'

import './SelectModal.scss'

type Props = {
  isOpen?: boolean,
  buyers: Buyer[],
  onSelectBuyer: (Buyer) => void,
  onClose: () => void
}

const PER_PAGE = 5

const SelectBuyerModal = ({ isOpen, buyers, onSelectBuyer, onClose }: Props) => {
  const [selectedBuyerId, setSelectedBuyerId] = useState('')
  const [page, setPage] = useState(1)

  const handleOnSelect = (_e, _i, rowId) => {
    const selectedBuyer = pageBuyers.find((b, i) => i === rowId)
    setSelectedBuyerId(selectedBuyer ? selectedBuyer.id : '')
  }

  const columns = [
    { title: 'Name' },
    { title: 'Admin' },
    { title: 'Signup date' }
  ]

  const pagination = (
    <Pagination
      perPage={PER_PAGE}
      itemCount={buyers.length}
      page={page}
      onSetPage={(_e, page) => setPage(page)}
      widgetId="pagination-options-menu-top"
    />
  )

  const pageBuyers = buyers.slice((page - 1) * PER_PAGE, page * PER_PAGE)

  const rows = pageBuyers.map(b => ({
    selected: b.id === selectedBuyerId,
    cells: [b.name, b.admin, b.createdAt]
  }))

  const onAccept = () => {
    const buyer = buyers.find(b => b.id === selectedBuyerId)
    if (buyer) {
      onSelectBuyer(buyer)
    }
  }

  return (
    <Modal
      title='Select a Buyer'
      isLarge={true}
      isOpen={isOpen}
      onClose={onClose}
      isFooterLeftAligned={true}
      actions={[
        <Button key='add' variant='primary' isDisabled={selectedBuyerId === -1} onClick={onAccept}>Add</Button>,
        <Button key='cancel' variant='secondary' onClick={onClose}>Cancel</Button>
      ]}
    >
      {/* Toolbar is a component in the css, but a layout in react, so the class names are mismatched (pf-c-toolbar vs pf-l-toolbar) Styling doesn't work, but if you change it to pf-c in the inspector, it works */}
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <InputGroup>
            <TextInput name="searchInput" id="searchInput" type="search" aria-label="search for a buyer" />
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
        aria-label="Buyers"
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

export { SelectBuyerModal }
