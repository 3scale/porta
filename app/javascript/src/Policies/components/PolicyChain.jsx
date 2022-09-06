// @flow

import * as React from 'react'
import {
  SortableContainer,
  SortableElement,
  SortableHandle,
  arrayMove
} from 'react-sortable-hoc'
import { PolicyTile } from 'Policies/components/PolicyTile'
import { HeaderButton } from 'Policies/components/HeaderButton'

import type { ThunkAction, ChainPolicy } from 'Policies/types'
import type { SortPolicyChainAction } from 'Policies/actions/PolicyChain'

type Props = {
  chain: Array<ChainPolicy>,
  actions: {
    openPolicyRegistry: () => ThunkAction,
    editPolicy: (ChainPolicy, number) => ThunkAction,
    sortPolicyChain: (Array<ChainPolicy>) => SortPolicyChainAction
  }
}

// $FlowIgnore[signature-verification-failure] missing react-sortable-hoc types
const DragHandle = SortableHandle(() => <div className="Policy-sortHandle"><i className="fa fa-sort" /></div>)

// $FlowIgnore[signature-verification-failure] missing react-sortable-hoc types
const SortableItem = SortableElement(({ value, editPolicy, index }) => {
  const edit = () => editPolicy(value, index)
  return (
    <li className={ value.enabled ? 'Policy' : 'Policy Policy--disabled' }>
      <PolicyTile policy={value} onClick={edit} title="Edit this Policy" />
      <DragHandle/>
    </li>
  )
})

// $FlowIgnore[signature-verification-failure] missing react-sortable-hoc types
const SortableList = SortableContainer(({ items, editPolicy }) => (
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
))

const PolicyChain = ({ chain, actions }: Props): React.Node => {
  const onSortEnd = ({ oldIndex, newIndex }) => {
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
