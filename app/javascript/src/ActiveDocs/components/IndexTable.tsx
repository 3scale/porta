import { useState } from 'react'
import {
  Toolbar,
  ToolbarContent,
  ToolbarItem,
  Button,
  Modal,
  ModalVariant
} from '@patternfly/react-core'
import {
  Table,
  ActionsColumn,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
  TableText
} from '@patternfly/react-table'

import { Pagination } from 'Common/components/Pagination'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { ajaxJSON } from 'utilities/ajax'
import { SwaggerUpdateHelpAction } from 'ActiveDocs/components/SwaggerUpdateHelpAction'

import type { ThProps, ISortBy } from '@patternfly/react-table'
import type { FunctionComponent } from 'react'

interface Props {
  activeDocs: ActiveDoc[];
  newActiveDocPath: string;
  isAudience: boolean;
  totalEntries: number;
}

interface ActiveDoc {
  actions: {
    toggle: { title: string; href: string };
    edit: { title: string; href: string };
    delete: { title: string; href: string };
  };
  href: string;
  id: number;
  name: string;
  service: string;
  state: string;
  swaggerUpdate?: { title: string; href: string };
  swaggerVersion: string;
  systemName: string;
}

const IndexTable: FunctionComponent<Props> = ({
  activeDocs,
  newActiveDocPath,
  isAudience,
  totalEntries
}) => {
  const [selectedDoc, setSelectedDoc] = useState<ActiveDoc | null>(null)

  const columns = { /* eslint-disable @typescript-eslint/naming-convention */
    name: 0,
    system_name: 1,
    published: 2,
    swagger_version: isAudience ? 4 : 3
  }

  type ColumnAttribute = keyof typeof columns

  const url = new URL(window.location.href)
  const sortParam = url.searchParams.get('sort') as ColumnAttribute | undefined

  const getSortParams = (attribute: ColumnAttribute): ThProps['sort'] => ({
    sortBy: {
      index: sortParam ? columns[sortParam] : undefined,
      direction: url.searchParams.get('direction') ?? 'desc'
    } as ISortBy,
    onSort: (_event, _index, direction) => {
      url.searchParams.set('sort', attribute)
      url.searchParams.set('direction', direction)
      window.location.replace(url.toString())
    },
    columnIndex: columns[attribute]
  })

  const closeModal = () => { setSelectedDoc(null) }

  const toggleDoc = (doc: ActiveDoc) => {
    ajaxJSON(doc.actions.toggle.href, { method: 'PUT' })
      .then(() => { window.location.reload() })
      .catch(console.error)
  }

  const deleteDoc = () => {
    if (!selectedDoc) {
      return
    }

    ajaxJSON(selectedDoc.actions.delete.href, { method: 'DELETE' })
      .then(() => { window.location.reload() })
      .catch(console.error)
  }

  return (
    <>
      <Toolbar id="top-toolbar">
        <ToolbarContent>
          <ToolbarItem>
            <Button component="a" href={newActiveDocPath} variant="primary">
              Add a new spec
            </Button>
          </ToolbarItem>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={totalEntries} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      <Table aria-label="Activedocs table">
        <Thead>
          <Tr>
            <Th sort={getSortParams('name')}>Name</Th>
            <Th sort={getSortParams('system_name')}>System name</Th>
            <Th sort={getSortParams('published')}>State</Th>
            {isAudience && <Th>API</Th>}
            <Th sort={getSortParams('swagger_version')}>Swagger version</Th>
          </Tr>
        </Thead>
        <Tbody>
          {activeDocs.map((doc) => (
            <Tr key={doc.id}>
              <Td dataLabel="Name">
                <a href={doc.href}>{doc.name}</a>
              </Td>
              <Td dataLabel="System name">
                <TableText>{doc.systemName}</TableText>
              </Td>
              <Td dataLabel="State">{doc.state}</Td>
              {isAudience && <Td dataLabel="API">{doc.service}</Td>}
              <Td dataLabel="System name">
                {doc.swaggerVersion}
                {/* eslint-disable-next-line react/jsx-props-no-spreading */}
                {doc.swaggerUpdate && <SwaggerUpdateHelpAction {...doc.swaggerUpdate} />}
              </Td>
              <Td isActionCell>
                <ActionsColumn
                  items={[{
                    title: doc.actions.toggle.title,
                    onClick: () => { toggleDoc(doc) }
                  }, {
                    title: doc.actions.edit.title,
                    onClick: () => { window.location.assign(doc.actions.edit.href) }
                  }, {
                    title: doc.actions.delete.title,
                    onClick: () => { setSelectedDoc(doc) }
                  }]}
                />
              </Td>
            </Tr>
          ))}
        </Tbody>
      </Table>

      <Toolbar id="bottom-toolbar">
        <ToolbarContent>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={totalEntries} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      <Modal
        actions={[
          <Button key="confirm" variant="danger" onClick={deleteDoc}>
            Delete spec
          </Button>,
          <Button key="cancel" variant="link" onClick={closeModal}>
            Cancel
          </Button>
        ]}
        isOpen={selectedDoc !== null}
        title="Are you sure?"
        variant={ModalVariant.small}
        onClose={closeModal}
      >
        Yes, I want to delete spec <b>{selectedDoc?.name}</b> forever.
      </Modal>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const IndexTableWrapper = (props: Props, containerId: string): void => { createReactWrapper(<IndexTable {...props} />, containerId) }

export type { Props }
export { IndexTable, IndexTableWrapper }
