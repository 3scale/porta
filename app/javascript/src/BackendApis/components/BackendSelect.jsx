// @flow

import * as React from 'react'

import { Button } from '@patternfly/react-core'
import { PlusCircleIcon } from '@patternfly/react-icons'
import { SelectWithModal } from 'Common'

import type { Backend } from 'Types'

import './BackendSelect.scss'

type Props = {
  backend: Backend | null,
  backends: Backend[],
  newBackendPath: string,
  onSelect: (Backend | null) => void
}

const BackendSelect = ({ backend, backends, newBackendPath, onSelect }: Props): React.Node => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'Private Base URL', propName: 'privateEndpoint' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <SelectWithModal
      label="Backend"
      fieldId="backend_api_config_backend_api_id"
      id="backend_api_config_backend_api_id"
      name="backend_api_config[backend_api_id]"
      // $FlowIssue backend is compatible with null
      item={backend}
      items={backends.map(b => ({ ...b, description: b.privateEndpoint }))}
      cells={cells}
      helperText={(
        <p className="hint">
          <Button variant="link" icon={<PlusCircleIcon />} component="a" href={newBackendPath} isInline>
            Create new Backend
          </Button>
        </p>
      )}
      modalTitle="Select a Backend"
      // $FlowIssue It should not complain since Record.id has union "number | string"
      onSelect={onSelect}
      header="Most recently created Backends"
      footer="View all Backends"
    />
  )
}
export { BackendSelect }
