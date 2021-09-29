// @flow

import * as React from 'react'

import {
  Button,
  ButtonVariant,
  Divider,
  Form,
  InputGroup,
  Pagination as PFPagination,
  PaginationVariant,
  TextInput,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableHeader,
  TableBody
} from '@patternfly/react-table'
import { CheckIcon, SearchIcon } from '@patternfly/react-icons'

import type { TabKey } from 'Metrics'
import type { Metric } from 'Types'

import './MetricsTable.scss'

type Props = {
  activeTabKey: TabKey,
  metrics: Metric[],
  metricsCount: number,
  createButton: React.Node
}

const MetricsTable = ({
  activeTabKey,
  metrics,
  metricsCount,
  createButton
}: Props): React.Node => {
  const url = new URL(window.location.href)
  const [searchText, setSearchText] = React.useState(url.searchParams.get('search[query]') || '')

  const isActiveTabMetrics = activeTabKey === 'metrics'

  const tableColumns = [
    { title: isActiveTabMetrics ? 'Metric' : 'Method' },
    { title: 'System name' },
    { title: 'Unit' },
    { title: 'Description' },
    { title: 'Mapped' }
  ]

  const tableRows = metrics.map(m => ({
    disableActions: false,
    cells: [
      { title: <Button href={m.path} component="a" variant="link" isInline>{m.name}</Button> },
      m.systemName,
      m.unit,
      m.description,
      { title: m.mapped ? <CheckIcon /> : '' } // or m.mapped && <CheckIcon />
    ]
  }))

  const selectPerPage = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', selectedPerPage)
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (page) => {
    url.searchParams.set('page', page)
    window.location.replace(url.toString())
  }

  const Pagination = ({ variant }: { variant?: string }) => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={metricsCount}
        perPage={Number(perPage) || 20}
        page={Number(page)}
        onPerPageSelect={selectPerPage}
        onNextClick={(_ev, page) => goToPage(page)}
        onPreviousClick={(_ev, page) => goToPage(page)}
        onFirstClick={(_ev, page) => goToPage(page)}
        onLastClick={(_ev, page) => goToPage(page)}
        onPageInput={(_ev, page) => goToPage(page)}
        perPageOptions={[10, 20].map(n => ({ title: String(n), value: n }))}
        variant={variant}
      />
    )
  }

  const handleOnSubmit = (e) => {
    if (searchText.length === 0) {
      removeEmptySearchQueryFromURL(e)
    }

    // Sphinx does not index less than 3 characters. Prevent form from being submitted.
    if (searchText.length < 3) {
      e.preventDefault()
    }
  }

  const removeEmptySearchQueryFromURL = (e: SyntheticEvent<HTMLFormElement>) => {
    if (!searchText) {
      // $FlowIgnore[incompatible-use] safe to assume it's there
      e.currentTarget.querySelector('[name="search[query]"]').remove()
      // $FlowIgnore[incompatible-use] safe to assume it's there
      e.currentTarget.querySelector('[name="utf8"]').remove()
    }
  }

  return (
    <>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <ToolbarItem>
          <Form acceptCharset="UTF-8" method="get" role="search" onSubmit={handleOnSubmit}>
            <InputGroup>
              <input name="utf8" type="hidden" value="✓" />
              <input name="tab" type="hidden" value={activeTabKey} />
              <TextInput
                placeholder={`Find a ${isActiveTabMetrics ? 'metric' : 'method'}`}
                name="search[query]"
                type="search"
                aria-label="Search"
                value={searchText}
                onChange={setSearchText}
                autoComplete="off"
              />
              <Button
                title="pepe"
                variant={ButtonVariant.control}
                aria-label="search button for search input"
                type="submit"
                isDisabled={searchText.length > 0 && searchText.length < 3}
              >
                <SearchIcon />
              </Button>
            </InputGroup>
          </Form>
        </ToolbarItem>
        <ToolbarItem className="pf-l-toolbar__item-left-align">
          {createButton}
        </ToolbarItem>
        <ToolbarItem align={{ default: 'alignRight' }}>
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Divider />
      <Table aria-label="Plans Table" cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
        <Pagination variant={PaginationVariant.bottom} />
      </Toolbar>
    </>
  )
}

export { MetricsTable }
