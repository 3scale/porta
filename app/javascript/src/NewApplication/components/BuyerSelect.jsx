// @flow

import * as React from 'react'

import { sortable } from '@patternfly/react-table'
import { fetchPaginatedBuyers } from 'NewApplication/data'
import { SelectWithModal } from 'Common'

import type { Buyer } from 'NewApplication/types'

type Props = {
  buyer: Buyer | null,
  buyers: Buyer[],
  buyersCount: number,
  onSelectBuyer: (Buyer | null) => void,
  buyersPath?: string,
  isDisabled?: boolean
}

const BuyerSelect = ({
  buyer,
  buyers,
  buyersCount,
  onSelectBuyer,
  buyersPath = '',
  isDisabled
}: Props): React.Node => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'Admin', propName: 'admin' },
    { title: 'Signup date', propName: 'createdAt', transforms: [sortable] }
  ]

  return (
    // $FlowFixMe[prop-missing] description not needed for selected buyer
    // $FlowIssue[incompatible-type-arg] id can be string too
    <SelectWithModal
      label="Account"
      fieldId="account_id"
      id="account_id"
      name="account_id"
      item={buyer}
      items={buyers.map(b => ({ ...b, description: `Admin: ${b.admin}` }))}
      itemsCount={buyersCount}
      cells={cells}
      onSelect={onSelectBuyer}
      fetchItems={(params) => fetchPaginatedBuyers(buyersPath, params)}
      header="Recently created accounts"
      isDisabled={isDisabled}
      title="Select an account"
      placeholder="Select an account"
      searchPlaceholder="Find an account"
      footerLabel="View all accounts"
    />
  )
}

export { BuyerSelect }
