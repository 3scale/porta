// @flow

import React from 'react'

import { SelectModal } from 'Common'
import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  // props here
}

const AddBackendForm = (props: Props) => {
  // logic here
  const backends = [
    { id: 0, name: 'Backend 0', url: 'http://foo.bar' },
    { id: 1, name: 'Backend 1', url: 'http://bar.foo' }
  ]

  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'Private base URL', propName: 'url' }
  ]

  const handleOnClose = () => {}

  const handleOnSelect = () => {}

  return (
    <SelectModal
      title="Select a Backend"
      item={null}
      // $FlowFixMe
      items={backends}
      onSelect={handleOnSelect}
      onClose={handleOnClose}
      cells={cells}
      isOpen
    />
  )
}

const AddBackendFormWrapper = (props: Props, containerId: string) => createReactWrapper(<AddBackendForm {...props} />, containerId)

export { AddBackendForm, AddBackendFormWrapper }
