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

import type { Record } from 'utilities/patternfly-utils'

import './SelectModal.scss'

type Props<T: Record> = {
  title: string,
  isOpen?: boolean,
  item: T | null,
  items: T[],
  onSelect: (T) => void,
  onClose: () => void,
  perPage?: number,
  cells: { title: string, propName: string }[]
}

const PER_PAGE_DEFAULT = 5

const SelectModal = <T: Record>({ title, isOpen, item, items, onSelect, onClose, perPage = PER_PAGE_DEFAULT, cells }: Props<T>) => {
  const [selectedId, setSelectedId] = useState(item ? item.id : '')
  const [page, setPage] = useState(1)

  const handleOnSelect = (_e, _i, rowId) => {
    setSelectedId(pageItems[rowId].id)
  }

  const pagination = (
    <Pagination
      perPage={perPage}
      itemCount={items.length}
      page={page}
      onSetPage={(_e, page) => setPage(page)}
      widgetId="pagination-options-menu-top"
    />
  )

  const pageItems = items.slice((page - 1) * perPage, page * perPage)

  const rows = pageItems.map((i) => ({
    selected: i.id === selectedId,
    cells: cells.map(({ propName }) => (i: {[string]: string})[propName])
  }))

  const onAccept = () => {
    const item = items.find(i => i.id === selectedId)
    if (item) {
      onSelect(item)
    }
  }

  return (
    <Modal
      isLarge
      title={title}
      isOpen={isOpen}
      onClose={onClose}
      isFooterLeftAligned={true}
      actions={[
        <Button key="Select" variant="primary" isDisabled={selectedId === -1} onClick={onAccept}>Add</Button>,
        <Button key="Cancel" variant="secondary" onClick={onClose}>Cancel</Button>
      ]}
    >
      {/* Toolbar is a component in the css, but a layout in react, so the class names are mismatched (pf-c-toolbar vs pf-l-toolbar) Styling doesn't work, but if you change it to pf-c in the inspector, it works */}
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <InputGroup>
            <TextInput name="searchInput" id="searchInput" type="search" aria-label="search for a item" />
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
        cells={cells}
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

export { SelectModal }
