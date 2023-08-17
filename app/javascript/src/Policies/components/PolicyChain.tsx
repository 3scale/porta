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
  DataListCell
} from '@patternfly/react-core'

import { HeaderButton } from 'Policies/components/HeaderButton'
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
  const arrayMove = (list: ChainPolicy[], startIndex: number, endIndex: number): ChainPolicy[] => {
    const result = [...list]
    const [removed] = result.splice(startIndex, 1)
    result.splice(endIndex, 0, removed)
    return result
  }

  const onDrag = (): boolean => {
    return true
  }

  const onDrop = (source: DraggableItemPosition, dest?: DraggableItemPosition): boolean => {
    if (dest) {
      const sortedChain = arrayMove(chain, source.index, dest.index)
      actions.sortPolicyChain(sortedChain)
      return true
    } else {
      return false
    }
  }

  return (
    <section className="PolicyChain">
      <header>
        <h2>Policy Chain</h2>
        <HeaderButton type="add" onClick={actions.openPolicyRegistry}>
          Add policy
        </HeaderButton>
      </header>
      <DragDrop onDrag={onDrag} onDrop={onDrop}>
        <Droppable hasNoWrapper>
          <DataList isCompact aria-label="Policies list">
            {chain.map((policy, index) => (
              <Draggable key={policy.uuid} hasNoWrapper>
                <DataListItem>
                  <DataListItemRow>
                    <DataListControl>
                      <DataListDragButton />
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
