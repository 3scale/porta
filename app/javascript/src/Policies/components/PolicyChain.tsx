import {
  SortableContainer,
  SortableElement,
  SortableHandle,
  arrayMove
} from 'react-sortable-hoc'
import { PolicyTile } from 'Policies/components/PolicyTile'
import { HeaderButton } from 'Policies/components/HeaderButton'

import type { SortEndHandler } from 'react-sortable-hoc'
import type { ChainPolicy, ThunkAction } from 'Policies/types'
import type { SortPolicyChainAction } from 'Policies/actions/PolicyChain'

type Props = {
  chain: Array<ChainPolicy>,
  actions: {
    openPolicyRegistry: () => ThunkAction,
    editPolicy: (policy: ChainPolicy, index: number) => ThunkAction,
    sortPolicyChain: (policies: ChainPolicy[]) => SortPolicyChainAction
  }
}

const DragHandle = SortableHandle(() => <div className="Policy-sortHandle"><i className="fa fa-sort" /></div>)

type SortableItemProps = {
  value: ChainPolicy,
  editPolicy: Props['actions']['editPolicy'],
  index: number
}

const SortableItem = SortableElement<SortableItemProps>(({ value, editPolicy, index }: SortableItemProps) => {
  const edit = () => editPolicy(value, index)
  return (
    <li className={value.enabled ? 'Policy' : 'Policy Policy--disabled'}>
      <PolicyTile policy={value} title="Edit this Policy" onClick={edit} />
      <DragHandle />
    </li>
  )
})

type SortableListProps = {
  items: Props['chain'],
  editPolicy: Props['actions']['editPolicy']
}

const SortableList = SortableContainer<SortableListProps>(({ items, editPolicy }: SortableListProps) => (
  <ul className="list-group">
    {items.map((policy, index) => (
      <SortableItem
        key={policy.uuid}
        editPolicy={editPolicy}
        index={index}
        value={policy}
      />
    ))}
  </ul>
))

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
        <HeaderButton type="add" onClick={actions.openPolicyRegistry}>
          Add policy
        </HeaderButton>
      </header>
      <SortableList
        useDragHandle
        editPolicy={actions.editPolicy}
        helperClass="Policy--sortable"
        items={chain}
        onSortEnd={onSortEnd}
      />
    </section>
  )
}

export {
  PolicyChain,
  SortableList,
  SortableItem,
  DragHandle,
  Props
}
