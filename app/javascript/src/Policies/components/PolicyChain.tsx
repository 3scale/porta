import * as React from 'react'
import {
  SortableContainer,
  SortableElement,
  SortableHandle,
  arrayMove,
  SortEndHandler
} from 'react-sortable-hoc'
import { PolicyTile } from 'Policies/components/PolicyTile'
import { HeaderButton } from 'Policies/components/HeaderButton'

import type { ThunkAction, ChainPolicy } from 'Policies/types'
import type { SortPolicyChainAction } from 'Policies/actions/PolicyChain'

type Props = {
  chain: Array<ChainPolicy>,
  actions: {
    openPolicyRegistry: () => ThunkAction,
    editPolicy: (arg1: ChainPolicy, arg2: number) => ThunkAction,
    sortPolicyChain: (arg1: Array<ChainPolicy>) => SortPolicyChainAction
  }
};

const DragHandle = SortableHandle(() => <div className="Policy-sortHandle"><i className="fa fa-sort" /></div>)

type SortableItemProps = {
  value: ChainPolicy,
  editPolicy: Props['actions']['editPolicy'],
  index: number
}

const SortableItem = SortableElement<SortableItemProps>(({ value, editPolicy, index }: SortableItemProps) => {
  const edit = () => editPolicy(value, index)
  return (
    <li className={ value.enabled ? 'Policy' : 'Policy Policy--disabled' }>
      <PolicyTile policy={value} onClick={edit} title="Edit this Policy" />
      <DragHandle/>
    </li>
  )
})

type SortableListProps = {
  items: Props['chain'],
  editPolicy: Props['actions']['editPolicy']
}

const SortableList = SortableContainer<SortableListProps>((({ items, editPolicy }: SortableListProps) => (
  <ul className="list-group">
    {items.map((policy, index) => (
      <SortableItem
        key={`item-${index}`}
        index={index}
        value={policy}
        editPolicy={editPolicy}
      />
    ))}
  </ul>
)))

const PolicyChain: React.FunctionComponent<Props> = ({
  chain,
  actions
}) => {
  const onSortEnd: SortEndHandler = ({ oldIndex, newIndex }) => {
    const sortedChain = arrayMove(chain, oldIndex, newIndex)
    actions.sortPolicyChain(sortedChain)
  }

  return (
    <section className="PolicyChain">
      <header>
        <h2>Policy Chain</h2>
        <HeaderButton type='add' onClick={actions.openPolicyRegistry}>
          Add policy
        </HeaderButton>
      </header>
      <SortableList
        items={chain}
        onSortEnd={onSortEnd}
        useDragHandle
        editPolicy={actions.editPolicy}
        helperClass="Policy--sortable"
      />
    </section>
  )
}

export {
  PolicyChain,
  SortableList,
  SortableItem,
  DragHandle
}
