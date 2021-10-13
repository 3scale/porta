// @flow

import * as React from 'react'

import { SelectWithModal } from 'Common'

import type { Buyer } from 'NewApplication/types'

type Props = {
  buyer: Buyer | null,
  buyers: Buyer[],
  onSelectBuyer: (Buyer | null) => void,
  isDisabled?: boolean
}

const BuyerSelect = ({ buyer, buyers, onSelectBuyer, isDisabled }: Props): React.Node => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'Admin', propName: 'admin' },
    { title: 'Signup date', propName: 'createdAt' }
  ]

  return (
    // $FlowFixMe[prop-missing] Implement async pagination
    <SelectWithModal
      label="Account"
      fieldId="account_id"
      id="account_id"
      name="account_id"
      // $FlowIgnore[incompatible-type] Buyer implements Record
      item={buyer}
      items={buyers.map(b => ({ ...b, description: `Admin: ${b.admin}` }))}
      itemsCount={buyers.length}
      cells={cells}
      // $FlowIssue[incompatible-type] It should not complain since Record.id has union "number | string"
      onSelect={onSelectBuyer}
      header="Most recently created Accounts"
      isDisabled={isDisabled}
      title="Select an Account"
      placeholder="Select an Account"
      footerLabel="View all Accounts"
    />
  )
}

export { BuyerSelect }
