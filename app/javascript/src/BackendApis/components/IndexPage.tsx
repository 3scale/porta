import {
  Button,
  Divider,
  Level,
  LevelItem,
  Pagination as PFPagination,
  PageSection,
  PageSectionVariants,
  PaginationVariant,
  Title,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import { Table, TableBody, TableHeader } from '@patternfly/react-table'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent, ReactElement } from 'react'
import type { IActions } from '@patternfly/react-table'
import type { OnPerPageSelect, PaginationProps } from '@patternfly/react-core'
import type { Backend } from 'BackendApis/types'

import './IndexPage.scss'

type Props = {
  newBackendPath: string,
  backends: Array<Backend>,
  backendsCount: number
}

const IndexPage: FunctionComponent<Props> = ({
  newBackendPath,
  backendsCount,
  backends
}) => {
  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Private base URL',
    'Linked products'
  ]

  const tableRows = backends.map((tableRow) => ({
    cells: [
      { title: <Button isInline component="a" href={tableRow.links[1].path} variant="link">{tableRow.name}</Button> },
      tableRow.systemName,
      // eslint-disable-next-line react/jsx-key
      <span className="api-table-timestamp">{tableRow.updatedAt}</span>,
      tableRow.privateEndpoint,
      tableRow.productsCount
    ]
  }))

  const linkToPage = (rowId: number, actionNumber: number) => {
    const { path } = backends[rowId].links[actionNumber]
    window.location.href = path
  }

  const tableActions: IActions = ['Edit', 'Overview', 'Analytics', 'Methods and Metrics', 'Mapping Rules'].map((title, i) => ({
    title,
    onClick: (_event, rowId) => linkToPage(rowId, i)
  }))

  const url = new URL(window.location.href)

  const selectPerPage: OnPerPageSelect = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', String(selectedPerPage))
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (page: any) => {
    url.searchParams.set('page', page)
    window.location.replace(url.toString())
  }

  // eslint-disable-next-line react/no-multi-comp
  const Pagination = ({ variant }: Pick<PaginationProps, 'variant'>): ReactElement<PaginationProps> => {
    const perPage = url.searchParams.get('per_page')
    const page = url.searchParams.get('page')
    return (
      <PFPagination
        itemCount={backendsCount}
        page={Number(page)}
        perPage={Number(perPage) || 20}
        perPageOptions={[ { title: '10', value: 10 }, { title: '20', value: 20 } ]}
        variant={variant}
        widgetId="pagination-options-menu-top"
        onFirstClick={(_ev, page) => goToPage(page)}
        onLastClick={(_ev, page) => goToPage(page)}
        onNextClick={(_ev, page) => goToPage(page)}
        onPerPageSelect={selectPerPage}
        onPreviousClick={(_ev, page) => goToPage(page)}
      />
    )
  }

  return (
    <PageSection id="backend-apis-index-page" variant={PageSectionVariants.light}>
      <Level>
        <LevelItem>
          <Title headingLevel="h1" size="2xl">Backends</Title>
        </LevelItem>
        <LevelItem>
          <Button component="a" href={newBackendPath} variant="primary">
            Create Backend
          </Button>
        </LevelItem>
      </Level>
      <p>Explore and manage all your internal APIs.</p>
      <Divider />
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="top-toolbar">
        <ToolbarItem>
          <ToolbarSearch placeholder="Find a backend" />
        </ToolbarItem>
        {/* <ToolbarItem align={{ default: 'alignRight' }}> TODO: did align do anything? */}
        <ToolbarItem>
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Table actions={tableActions} aria-label="Backend APIs Table" cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="bottom-toolbar">
        {/* <ToolbarItem align={{ default: 'alignRight' }}> TODO: did align do anything? */}
        <ToolbarItem>
          <Pagination variant={PaginationVariant.bottom} />
        </ToolbarItem>
      </Toolbar>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const BackendsIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<IndexPage {...props} />, containerId)

export { IndexPage, BackendsIndexPageWrapper, Props }
