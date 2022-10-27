import { sortable } from '@patternfly/react-table'
import { fetchPaginatedBuyers } from 'NewApplication/data/Buyers'
import { SelectWithModal } from 'Common/components/SelectWithModal'

import type { Props as SelectWithModalProps } from 'Common/components/SelectWithModal'
import type { Buyer } from 'NewApplication/types'

interface Props {
  buyer: Buyer | null;
  buyers: Buyer[];
  buyersCount: number;
  onSelectBuyer: (buyer: Buyer | null) => void;
  buyersPath?: string;
  isDisabled?: boolean;
}

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
      cells={cells}
      fetchItems={(params) => fetchPaginatedBuyers(buyersPath, params)}
      footerLabel="View all accounts"
      header="Recently created accounts"
      id="account_id"
      isDisabled={isDisabled}
      item={buyer}
      items={buyers.map(b => ({ ...b, description: `Admin: ${b.admin}` }))}
      itemsCount={buyersCount}
      label="Account"
      name="account_id"
      placeholder="Select an account"
      searchPlaceholder="Find an account"
      title="Select an account"
      onSelect={onSelectBuyer}
    />
  )
}

export { BuyerSelect, Props }
