
import { sortable } from '@patternfly/react-table'
import { fetchPaginatedBuyers } from 'NewApplication/data'
import { SelectWithModal, Props as SelectWithModalProps } from 'Common/components/SelectWithModal'

import type { Buyer } from 'NewApplication/types'

type Props = {
  buyer: Buyer | null,
  buyers: Buyer[],
  buyersCount: number,
  onSelectBuyer: (arg1: Buyer | null) => void,
  buyersPath?: string,
  isDisabled?: boolean
};

const BuyerSelect: React.FunctionComponent<Props> = ({
  buyer,
  buyers,
  buyersCount,
  onSelectBuyer,
  buyersPath = '',
  isDisabled
}) => {
  const cells: SelectWithModalProps<Buyer>['cells'] = [
    { title: 'Name', propName: 'name' },
    { title: 'Admin', propName: 'admin' },
    { title: 'Signup date', propName: 'createdAt', transforms: [sortable] }
  ]

  return (
    <SelectWithModal
      label="Account"
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
