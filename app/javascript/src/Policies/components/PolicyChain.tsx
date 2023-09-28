import {
  DragDrop,
  Droppable,
  DataList,
  Draggable,
  DataListItem,
  DataListItemRow,
  DataListControl,
  DataListDragButton,
  DataListItemCells,
  DataListCell,
  Button,
  SearchInput,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import { useMemo, useState } from 'react'
import escapeRegExp from 'lodash.escaperegexp'

import { PolicyTile } from 'Policies/components/PolicyTile'

import type { DraggableItemPosition } from '@patternfly/react-core'
import type { ChainPolicy } from 'Policies/types/Policies'
import type { ThunkAction } from 'Policies/types/Actions'
import type { SortPolicyChainAction } from 'Policies/actions/PolicyChain'

interface Props {
  chain: ChainPolicy[];
  actions: {
    openPolicyRegistry: () => ThunkAction;
    editPolicy: (policy: ChainPolicy, index: number) => ThunkAction;
    sortPolicyChain: (policies: ChainPolicy[]) => SortPolicyChainAction;
  };
}

const PolicyChain: React.FunctionComponent<Props> = ({
  chain,
  actions
}) => {
  const [search, setSearch] = useState('')

  const items = useMemo(() => {
    const term = new RegExp(escapeRegExp(search), 'i')

    return search.length > 0
      ? chain.filter(policy => term.test(policy.humanName))
      : chain
  }, [search, chain])

  const arrayMove = (list: ChainPolicy[], startIndex: number, endIndex: number): ChainPolicy[] => {
    const result = [...list]
    const [removed] = result.splice(startIndex, 1)
    result.splice(endIndex, 0, removed)
    return result
  }

  const onDrop = (source: DraggableItemPosition, dest?: DraggableItemPosition): boolean => {
    if (search.length === 0 && dest) {
      const sortedChain = arrayMove(chain, source.index, dest.index)
      actions.sortPolicyChain(sortedChain)
      return true
    } else {
      return false
    }
  }

  const handleOnSearch = (event: React.FormEvent<HTMLInputElement>, value: string) => {
    setSearch(value)
  }

  return (
    <section>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <SearchInput
              placeholder="Find by name"
              value={search}
              onChange={handleOnSearch}
              onClear={() => { setSearch('') }}
            />
          </ToolbarItem>
          <ToolbarItem>
            <Button variant="primary" onClick={actions.openPolicyRegistry}>Add policy</Button>
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      <DragDrop onDrop={onDrop}>
        <Droppable hasNoWrapper>
          <DataList isCompact aria-label="Policies list">
            {items.map((policy, index) => (
              <Draggable key={policy.uuid} hasNoWrapper>
                <DataListItem>
                  <DataListItemRow>
                    <DataListControl>
                      <DataListDragButton isDisabled={search.length > 0} />
                    </DataListControl>

                    <DataListItemCells
                      dataListCells={[
                        <DataListCell key={policy.uuid}>
                          <PolicyTile
                            isDisabled={!policy.enabled}
                            policy={policy}
                            title="Edit this Policy"
                            onClick={() => actions.editPolicy(policy, index)}
                          />
                        </DataListCell>
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
              </Draggable>
            ))}
          </DataList>
        </Droppable>
      </DragDrop>
    </section>
  )
}

export type { Props }
export { PolicyChain }
