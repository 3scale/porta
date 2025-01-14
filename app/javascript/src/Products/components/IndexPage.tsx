import {
  Button,
  Divider,
  PageSection,
  PageSectionVariants,
  Text,
  TextContent,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import {
  Table,
  TableBody,
  TableHeader,
  wrappable
} from '@patternfly/react-table'

import { Pagination } from 'Common/components/Pagination'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { IActionsResolver } from '@patternfly/react-table'
import type { Product } from 'Products/types'

import './IndexPage.scss'

interface Props {
  newProductPath?: string;
  products: Product[];
  productsCount: number;
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
    { title: 'Backends contained', transforms: [wrappable] },
    'Unread alerts'
  ]

  const tableRows = products.map(p => ({
    cells: [
      { title: <Button isInline component="a" href={p.link} variant="link">{p.name}</Button> },
      p.systemName,
      <span key={p.systemName} className="api-table-timestamp">{p.updatedAt}</span>,
      p.appsCount,
      p.backendsCount,
      p.unreadAlertsCount
    ]
  }))

  const actionResolver: IActionsResolver = (_rowData, { rowIndex }) => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const product = products[rowIndex!]

    return product.links.map(link => ({
      title: link.name,
      onClick: () => { window.location.href = link.path }
    }))
  }

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">Products</Text>
          <Text component="p">Explore and manage all customer-facing APIs that contain one or more of your Backends.</Text>
        </TextContent>
      </PageSection>

      <Divider />

      <PageSection variant={PageSectionVariants.light}>
        <Toolbar id="top-toolbar">
          <ToolbarContent>
            <ToolbarItem spacer={{ default: 'spacerMd' }} variant="search-filter">
              <ToolbarSearch placeholder="Find a product" />
            </ToolbarItem>
            {newProductPath && (
              <ToolbarItem>
                <Button component="a" href={newProductPath} variant="primary">
                  Create a product
                </Button>
              </ToolbarItem>
            )}
            <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
              <Pagination itemCount={productsCount} />
            </ToolbarItem>
          </ToolbarContent>
        </Toolbar>
        <Table actionResolver={actionResolver} aria-label="Products Table" cells={tableColumns} rows={tableRows}>
          <TableHeader />
          <TableBody />
        </Table>
        <Toolbar id="bottom-toolbar">
          <ToolbarContent>
            <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
              <Pagination itemCount={productsCount} />
            </ToolbarItem>
          </ToolbarContent>
        </Toolbar>
      </PageSection>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ProductsIndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<IndexPage {...props} />, containerId) }

export type { Props }
export { IndexPage, ProductsIndexPageWrapper }
