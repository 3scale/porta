import {
  Button,
  Divider,
  Level,
  LevelItem,
  PageSection,
  PageSectionVariants,
  PaginationVariant,
  Title,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import { Pagination } from 'Common/components/Pagination'
import { Table, TableBody, TableHeader } from '@patternfly/react-table'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Product } from 'Products/types'

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
          <Pagination itemCount={productsCount} />
        </ToolbarItem>
      </Toolbar>
      <Table actions={tableActions} aria-label="Products Table" cells={tableColumns} rows={tableRows}>
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between" id="bottom-toolbar">
        <ToolbarItem>
          <Pagination itemCount={productsCount} variant={PaginationVariant.bottom} />
        </ToolbarItem>
      </Toolbar>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ProductsIndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<IndexPage {...props} />, containerId)

export { IndexPage, ProductsIndexPageWrapper, Props }
