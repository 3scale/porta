import {
  Button,
  Divider,
  Modal,
  ModalVariant,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import {
  TableComposable,
  Thead,
  Th,
  Tr,
  Tbody,
  Td,
  ActionsColumn
} from '@patternfly/react-table'
import { useState } from 'react'

import { Pagination } from 'Common/components/Pagination'
import { ajaxJSON } from 'utilities/ajax'
import { toast } from 'utilities/toast'
import { getSortParams } from 'utilities/patternfly-utils'

import type { IAlert } from 'Types'
import type { FunctionComponent } from 'react'

interface Integration {
  createdOn: string;
  id: number;
  name: string;
  editPath: string;
  path: string;
  published: boolean;
  state: string;
  users: number;
}

interface Props {
  count: number;
  deleteTemplateHref: string;
  items: Integration[];
  newHref: string;
}

const AuthenticationProvidersTable: FunctionComponent<Props> = ({
  count,
  deleteTemplateHref,
  items,
  newHref
}) => {
  const [itemToBeDeleted, setItemToBeDeleted] = useState<Integration | undefined>(undefined)

  const columns = [
    { label: 'Integration' },
    { label: 'Created on', sort: getSortParams(1, 'created_at') },
    { label: 'Number of users' },
    { label: 'State', sort: getSortParams(3, 'published') }
  ]

  const handleDelete = () => {
    if (!itemToBeDeleted) {
      return
    }

    void ajaxJSON<Required<IAlert>>(deleteTemplateHref.replace(':id', String(itemToBeDeleted.id)), { method: 'Delete' })
      .then(res => res.json())
      .then(({ type, message, redirect }) => {
        if (type === 'danger') {
          toast(message, type)
          closeModal()
        } else if (redirect) {
          window.location.replace(redirect)
        }
      })
  }

  const closeModal = () => { setItemToBeDeleted(undefined) }

  return (
    <>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem>
            <Button
              isInline
              component="a"
              href={newHref}
              variant="primary"
            >
              Create a new SSO integration
            </Button>
          </ToolbarItem>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={count} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
      <Divider />
      <TableComposable aria-label="Authentication providers table" ouiaId="authorization-providers-table">
        <Thead>
          <Tr>
            {columns.map(({ label, sort }) => (
              <Th key={label} sort={sort}>{label}</Th>
            ))}
          </Tr>
        </Thead>
        <Tbody>
          {items.map(item => (
            <Tr key={item.id}>
              <Td dataLabel="Integration">
                <a href={item.path}>{item.name}</a>
              </Td>
              <Td dataLabel="Created on">{item.createdOn}</Td>
              <Td dataLabel="Number of users">{item.users}</Td>
              <Td dataLabel="State">{item.state}</Td>
              <Td isActionCell>
                <ActionsColumn items={[{
                  ouiaId: 'edit',
                  title: 'Edit',
                  onClick: () => { window.location.href = item.editPath }
                }, {
                  ouiaId: 'delete',
                  title: 'Delete',
                  onClick: () => { setItemToBeDeleted(item) }
                }]}
                />
              </Td>
            </Tr>
          ))}
        </Tbody>
      </TableComposable>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={count} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      {itemToBeDeleted && (
        <Modal
          isOpen
          actions={[
            <Button key="confirm" variant="danger" onClick={handleDelete}>Delete</Button>,
            <Button key="cancel" variant="link" onClick={closeModal}>Cancel</Button>
          ]}
          title="Delete integration"
          titleIconVariant="warning"
          variant={ModalVariant.small}
          onClose={closeModal}
        >
          Are you sure you want to delete the {itemToBeDeleted.name} integration?
        </Modal>
      )}
    </>
  )
}

export type { Props }
export { AuthenticationProvidersTable }
