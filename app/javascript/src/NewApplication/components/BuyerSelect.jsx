// @flow

import React from 'react'

import { SelectWithModal } from 'Common'

import type { Buyer } from 'NewApplication/types'

type Props = {
  buyer: Buyer | null,
  buyers: Buyer[],
  onSelectBuyer: (Buyer | null) => void,
  isDisabled?: boolean
}

const BuyerSelect = ({ buyer, buyers, onSelectBuyer, isDisabled }: Props) => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'Admin', propName: 'admin' },
    { title: 'Signup date', propName: 'createdAt' }
  ]

  return (
    <SelectWithModal
      label="Account"
      fieldId="account_id"
      id="account_id"
      name="account_id"
      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      item={buyer}
      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      items={buyers}
      cells={cells}
      modalTitle="Select an Account"
      onSelect={onSelectBuyer}
      header="Most recently created Accounts"
      footer="View all Accounts"
      isDisabled={isDisabled}
    />
  )
}

export { BuyerSelect }
