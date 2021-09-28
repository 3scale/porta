// @flow

import * as React from 'react'

import { sortable } from '@patternfly/react-table'
import { fetchPaginatedBuyers } from 'NewApplication'
import { SelectWithModal } from 'Common'

import type { Buyer } from 'NewApplication/types'

type Props = {
  buyer: Buyer | null,
  mostRecentlyCreatedBuyers: Array<Buyer>,
  buyersCount: number,
  onSelectBuyer: (Buyer | null) => void,
  buyersPath: string,
  isDisabled?: boolean
}

const cells = [
  { title: 'Name', propName: 'name' },
  { title: 'Admin', propName: 'admin' },
  { title: 'Signup date', propName: 'createdAt', transforms: [sortable] }
]

const BuyerSelect = ({
  buyer,
  mostRecentlyCreatedBuyers,
  buyersCount,
  onSelectBuyer,
  buyersPath,
  isDisabled
}: Props): React.Node => (
  // $FlowIssue[incompatible-type-arg] id can be string too
  <SelectWithModal
    label="Account"
    fieldId="account_id"
    id="account_id"
    name="account_id"
    item={buyer}
    items={mostRecentlyCreatedBuyers}
    itemsCount={buyersCount}
    cells={cells}
    onSelect={onSelectBuyer}
    fetchItems={(params) => fetchPaginatedBuyers(buyersPath, params)}
    header="Most recently created Accounts"
    title="Select an Account"
    isDisabled={isDisabled}
    placeholder="Select an Account"
    footerLabel="View all Accounts"
  />
)

export { BuyerSelect }
