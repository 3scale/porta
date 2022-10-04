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

import type { PaginationProps } from '@patternfly/react-core'
import type { Product } from 'Products/types'
import type { ReactElement } from 'react'

import './IndexPage.scss'

type Props = {
  newProductPath: string,
  products: Array<Product>,
  productsCount: number
}

const IndexPage: React.FunctionComponent<Props> = ({
  newProductPath,
  productsCount,
  products
}) => {
  const tableColumns = [
    'Name',
    'System name',
    'Last updated',
    'Applications',
    'Backends contained',
    'Unread alerts'
  ]

  const tableRows = products.map(tableRow => ({
    cells: [
      { title: <Button isInline component="a" href={tableRow.links[1].path} variant="link">{tableRow.name}</Button> },
      tableRow.systemName,
      // eslint-disable-next-line react/jsx-key
      <span className="api-table-timestamp">{tableRow.updatedAt}</span>,
      tableRow.appsCount,
      tableRow.backendsCount,
      tableRow.unreadAlertsCount
    ]
  }))

  const linkToPage = (rowId: any, actionNumber: number) => {
    const { path } = products[rowId].links[actionNumber]
    window.location.href = path
  }

  const tableActions = ['Edit', 'Overview', 'Analytics', 'Applications', 'ActiveDocs', 'Integration'].map((title, i) => ({
    title,
    onClick: (_event: any, rowId: any) => linkToPage(rowId, i)
  }))

  const url = new URL(window.location.href)

  const selectPerPage = (_event: any, selectedPerPage: any) => {
    url.searchParams.set('per_page', selectedPerPage)
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
        itemCount={productsCount}
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
    <PageSection id="products-index-page" variant={PageSectionVariants.light}>
      <Level>
        <LevelItem>
          <Title headingLevel="h1" size="2xl">Products</Title>
        </LevelItem>
        <LevelItem>
          <Button component="a" href={newProductPath} variant="primary">
            Create Product
          </Button>
        </LevelItem>
      </Level>
      <p>Explore and manage all customer-facing APIs that contain one or more of your Backends.</p>
      <Divider />
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="top-toolbar">
        <ToolbarItem>
          <ToolbarSearch placeholder="Find a product" />
        </ToolbarItem>
        <ToolbarItem> {/* TODO: add alignment={{ default: 'alignRight' }} after upgrading @patternfly/react-core */}
          <Pagination />
        </ToolbarItem>
      </Toolbar>
      <Table actions={tableActions} aria-label="Products Table" cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="bottom-toolbar">
        <ToolbarItem>
          <Pagination variant={PaginationVariant.bottom} />
        </ToolbarItem>
      </Toolbar>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ProductsIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<IndexPage {...props} />, containerId)

export { IndexPage, ProductsIndexPageWrapper, Props }
