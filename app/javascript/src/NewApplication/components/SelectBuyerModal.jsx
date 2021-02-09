// @flow

import React from 'react'

import { SelectModal } from 'Common'

import type { Buyer } from 'NewApplication/types'

type Props = {
  isOpen?: boolean,
  buyer: Buyer | null,
  buyers: Buyer[],
  onSelectBuyer: (Buyer) => void,
  onClose: () => void
}

const SelectBuyerModal = ({ isOpen, buyer, buyers, onSelectBuyer, onClose }: Props) => {
  const columns = [
    { title: 'Name' },
    { title: 'Admin' },
    { title: 'Signup date' }
  ]

  const cells = ['name', 'admin', 'createdAt']

  return (
    <SelectModal
      title="Select a Buyer"
      isOpen={isOpen}
      item={buyer}
      items={buyers}
      onSelect={onSelectBuyer}
      onClose={onClose}
      columns={columns}
      cells={cells}
    />
  )
}

export { SelectBuyerModal }
