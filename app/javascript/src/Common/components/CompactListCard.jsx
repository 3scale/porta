// @flow

import * as React from 'react'

import {
  Button,
  ButtonVariant,
  Card,
  CardBody,
  InputGroup,
  TextInput
} from '@patternfly/react-core'
import { Table, TableBody } from '@patternfly/react-table'
import { SearchIcon } from '@patternfly/react-icons'
import { MicroPagination } from 'Common'

import './CompactListCard.scss'

export type CompactListItem = {
  name: string,
  href: string,
  description: string
}

type Props = {
  columns: Array<string>,
  items: Array<CompactListItem>,
  searchInputRef: {| current: HTMLInputElement | null |},
  onSearch: (term?: string) => void,
  page: number,
  setPage: number => void,
  perPage?: number,
  searchInputPlaceholder?: string,
  tableAriaLabel?: string
}

const PER_PAGE = 5

const CompactListCard = ({
  columns,
  items,
  searchInputRef,
  onSearch,
  page,
  setPage,
  perPage = PER_PAGE,
  searchInputPlaceholder,
  tableAriaLabel
}: Props): React.Node => {
  const lastPage = Math.ceil(items.length / perPage)
  const pageItems = items.slice((page - 1) * perPage, page * perPage)

  const rows = pageItems.map(i => ({
    cells: [
      { title: <Button href={i.href} component="a" variant="link" isInline>{i.name}</Button> },
      i.description
    ]
  }))

  const header = (
    <InputGroup>
      <TextInput
        type="search"
        aria-label="search for an item"
        ref={searchInputRef}
        placeholder={searchInputPlaceholder}
      />
      <Button variant={ButtonVariant.control} aria-label="search button for search input" onClick={onSearch} data-testid="search">
        <SearchIcon />
      </Button>
    </InputGroup>
  )

  return (
    <Card>
      <CardBody>
        <Table
          header={header}
          aria-label={tableAriaLabel}
          cells={columns}
          rows={rows}
        >
          <TableBody />
        </Table>
        <MicroPagination page={page} setPage={setPage} lastPage={lastPage} />
      </CardBody>
    </Card>
  )
}

export { CompactListCard }
