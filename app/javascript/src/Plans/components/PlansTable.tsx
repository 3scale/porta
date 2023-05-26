import { useState } from 'react'
import { Button, Divider, Pagination, Toolbar, ToolbarContent, ToolbarItem } from '@patternfly/react-core'
import { sortable, Table, TableHeader, TableBody } from '@patternfly/react-table'

import * as flash from 'utilities/flash'
import { ajax } from 'utilities/ajax'
import { waitConfirm } from 'utilities/confirm-dialog'
import { ToolbarSearch } from 'Common/components/ToolbarSearch'

import type { FunctionComponent } from 'react'
import type { Action, Plan } from 'Types'
import type { IActionsResolver, ISortBy, OnSort } from '@patternfly/react-table'

interface Props {
  createButton?: {
    href: string;
    label: string;
  };
  columns: {
    attribute: string;
    title: string;
  }[];
  plans: Plan[];
  count: number;
}

const PlansTable: FunctionComponent<Props> = ({
  createButton,
  columns,
  plans: initialPlans,
  count
}) => {
  const [plans, setPlans] = useState<Plan[]>(initialPlans)
  const [isLoading, setIsLoading] = useState<boolean>(false)

  const handleActionCopy = (path: string) => ajax(path, { method: 'POST' })
    .then(data => data.json()
      .then((res: { notice: string; plan: string; error: string }) => {
        if (data.status === 201) {
          flash.notice(res.notice)
          const newPlan = JSON.parse(res.plan) as Plan
          setPlans([...plans, newPlan])
        } else if (data.status === 422) {
          flash.error(res.error)
        }
      })
    )
    .catch(err => {
      console.error(err)
      flash.error('An error ocurred. Please try again later.')
    })
    .finally(() => { setIsLoading(false) })

  const handleActionDelete = (path: string) => waitConfirm('Are you sure?')
    .then(confirmed => {
      if (confirmed) {
        return ajax(path, { method: 'DELETE' })
          .then(data => data.json()
            .then((res: { notice: string; id: number }) => {
              if (data.status === 200) {
                flash.notice(res.notice)
                const purgedPlans = plans.filter(p => p.id !== res.id)
                setPlans(purgedPlans)
              }
            }))
      }
    })
    .catch(err => {
      console.error(err)
      flash.error('An error ocurred. Please try again later.')
    })
    .finally(() => { setIsLoading(false) })

  const handleActionPublishHide = (path: string) => ajax(path, { method: 'POST' })
    .then(data => data.json()
      .then((res: { notice: string; plan: string; error: string }) => {
        if (data.status === 200) {
          flash.notice(res.notice)
          const newPlan = JSON.parse(res.plan) as Plan
          const i = plans.findIndex(p => p.id === newPlan.id)
          plans[i] = newPlan
          setPlans(plans)
        } else if (data.status === 406) {
          flash.error(res.error)
        }
      })
    )
    .catch(err => {
      console.error(err)
      flash.error('An error ocurred. Please try again later.')
    })
    .finally(() => { setIsLoading(false) })

  const handleAction = ({ title, path }: Action) => {
    if (isLoading) {
      // Block table or something when is loading, show user feedback
      return
    }

    setIsLoading(true)

    switch (title) {
      case 'Copy':
        void handleActionCopy(path)
        break
      case 'Delete':
        void handleActionDelete(path)
        break
      case 'Publish':
      case 'Hide':
        void handleActionPublishHide(path)
        break
      default:
        console.error(`Unknown action: ${title}`)
    }
  }

  const tableColumns = columns.map(c => ({ title: c.title, transforms: [sortable] }))

  const tableRows = plans.map(p => ({
    disableActions: false,
    cells: [
      { title: <Button isInline component="a" href={p.editPath} variant="link">{p.name}</Button> },
      { title: <Button isInline component="a" href={p.contractsPath} variant="link">{p.contracts}</Button> },
      p.state
    ]
  }))

  const actionResolver: IActionsResolver = (_rowData, { rowIndex }) =>
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- safe to assume rowIndex is not undefined
    plans[rowIndex!].actions.map(a => ({
      title: a.title,
      onClick: () => { handleAction(a) }
    }))

  const url = new URL(window.location.href)

  const sortParam = url.searchParams.get('sort')
  const sortBy: ISortBy = {
    index: columns.findIndex(c => c.attribute === sortParam),
    direction: (url.searchParams.get('direction') ?? 'desc') as ISortBy['direction']
  }

  const onSort: OnSort = (_event, index, direction) => {
    url.searchParams.set('direction', direction)
    url.searchParams.set('sort', columns[index].attribute)
    window.location.replace(url.toString())
  }

  return (
    <>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <ToolbarSearch placeholder="Find a plan" />
          </ToolbarItem>
          {createButton && (
            <ToolbarItem>
              <Button
                isInline
                component="a"
                href={createButton.href}
                variant="primary"
              >
                {createButton.label}
              </Button>
            </ToolbarItem>
          )}
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={count} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
      <Divider />
      <Table
        actionResolver={actionResolver}
        aria-label="Plans Table"
        cells={tableColumns}
        ouiaId="plans-table"
        rows={tableRows}
        sortBy={sortBy}
        onSort={onSort}
      >
        <TableHeader />
        <TableBody />
      </Table>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem alignment={{ default: 'alignRight' }} variant="pagination">
            <Pagination itemCount={count} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
    </>
  )
}

export type { Props }
export { PlansTable }
