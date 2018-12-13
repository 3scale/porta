// @flow

import React from 'react'
import {
  SortableContainer,
  SortableElement,
  SortableHandle,
  arrayMove
} from 'react-sortable-hoc'

import type { ThunkAction } from '../types/index'
import type { ChainPolicy } from '../types/Policies'
import type { SortPolicyChainAction } from '../actions/PolicyChain'

type Props = {
  visible: boolean,
  chain: Array<ChainPolicy>,
  actions: {
    openPolicyRegistry: () => ThunkAction,
    editPolicy: (ChainPolicy, number) => ThunkAction,
    sortPolicyChain: (Array<ChainPolicy>) => SortPolicyChainAction
  }
}

const DragHandle = SortableHandle(() => <div className="Policy-sortHandle"><i className="fa fa-sort" /></div>)

const SortableItem = SortableElement(({value, editPolicy, index}) => {
  const edit = () => editPolicy(value, index)
  return (
    <li className={ value.enabled ? 'Policy' : 'Policy Policy--disabled' }>
      <article onClick={edit} className="Policy-article" title="Configure this policy.">
        <h3 className="Policy-name">{value.humanName}</h3>
        <p className="Policy-version-and-summary">
          <span className="Policy-version">
            {value.version}
          </span>
          {' - '}
          <span title={value.summary} className="Policy-summary">
            {value.summary}
          </span>
        </p>
      </article>
      <DragHandle/>
    </li>
  )
})

const SortableList = SortableContainer(({items, visible, editPolicy}) => {
  return (
    <ul className={(visible ? 'list-group' : 'is-hidden list-group')}>
      {items.map((policy, index) => (
        <SortableItem
          key={`item-${index}`}
          index={index}
          value={policy}
          editPolicy={editPolicy}
        />
      ))}
    </ul>
  )
})

const AddPolicyButton = ({openPolicyRegistry}: {openPolicyRegistry: () => ThunkAction}) => {
  return (
    <div className="PolicyChain-addPolicy" onClick={openPolicyRegistry}>
      <i className="fa fa-plus-circle" /> Add Policy
    </div>
  )
}

const PolicyChain = ({chain, visible, actions}: Props) => {
  const onSortEnd = ({oldIndex, newIndex}) => {
    const sortedChain = arrayMove(chain, oldIndex, newIndex)
    actions.sortPolicyChain(sortedChain)
  }

  return (
    <section className="PolicyChain">
      <header className={(visible ? 'PolicyChain-header' : 'is-hidden PolicyChain-header')}>
        <h2 className="PolicyChain-title">Policy Chain</h2>
        <AddPolicyButton openPolicyRegistry={actions.openPolicyRegistry} />
      </header>
      <SortableList
        items={chain}
        visible={visible}
        onSortEnd={onSortEnd}
        useDragHandle={true}
        editPolicy={actions.editPolicy}
      />
    </section>
  )
}

export {
  PolicyChain,
  SortableList,
  SortableItem,
  AddPolicyButton,
  DragHandle
}
