
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
import { MicroPagination } from 'Common/components/MicroPagination'

import './CompactListCard.scss'

export type CompactListItem = {
  name: string,
  href: string,
  description: string
}

type Props = {
  columns: Array<string>,
  items: Array<CompactListItem>,
  searchInputRef: { current: HTMLInputElement | null },
  onSearch: (term?: string) => void,
  page: number,
  setPage: (arg1: number) => void,
  perPage?: number,
  searchInputPlaceholder?: string,
  tableAriaLabel?: string
}

const PER_PAGE = 5

const CompactListCard: React.FunctionComponent<Props> = ({
  columns,
  items,
  searchInputRef,
  onSearch,
  page,
  setPage,
  perPage = PER_PAGE,
  searchInputPlaceholder,
  tableAriaLabel
}) => {
  const lastPage = Math.ceil(items.length / perPage)
  const pageItems = items.slice((page - 1) * perPage, page * perPage)

  const rows = pageItems.map(i => ({
    cells: [
      { title: <Button isInline component="a" href={i.href} variant="link">{i.name}</Button> },
      i.description
    ]
  }))

  const header = (
    <InputGroup>
      <TextInput
        aria-label="search for an item"
        placeholder={searchInputPlaceholder}
        ref={searchInputRef}
        type="search"
      />
      {/* <Button variant={ButtonVariant.control} aria-label="search button for search input" onClick={onSearch} data-testid="search">  TODO: onSearch funcionaba con el evento del click??? */}
      <Button aria-label="search button for search input" data-testid="search" variant={ButtonVariant.control} onClick={() => onSearch()}>
        <SearchIcon />
      </Button>
    </InputGroup>
  )

  return (
    <Card>
      <CardBody>
        <Table
          aria-label={tableAriaLabel}
          cells={columns}
          header={header}
          rows={rows}
        >
          <TableBody />
        </Table>
        <MicroPagination lastPage={lastPage} page={page} setPage={setPage} />
      </CardBody>
    </Card>
  )
}

export { CompactListCard, Props }
