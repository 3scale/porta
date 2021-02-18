// @flow

import React from 'react'

import { SelectModal } from 'Common'

import type { Backend } from 'Types'

type Props = {
  backend: Backend | null,
  backends: Backend[],
  onSelectBackend: (Backend) => void,
  onClose: () => void,
  isOpen?: boolean
}

const BackendSelectModal = ({ backend, backends, onSelectBackend, onClose, isOpen }: Props) => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'Private Base URL', propName: 'privateEndpoint' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <SelectModal
      title="Select a Backend"
      isOpen={isOpen}
      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      item={backend}
      // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
      items={backends}
      onSelect={onSelectBackend}
      onClose={onClose}
      cells={cells}
    />
  )
}

export { BackendSelectModal }
