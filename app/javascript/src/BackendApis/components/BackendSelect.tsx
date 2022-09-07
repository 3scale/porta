import * as React from 'react';

import { Button } from '@patternfly/react-core'
import { PlusCircleIcon } from '@patternfly/react-icons'
import { SelectWithModal } from 'Common'

import type { Backend } from 'Types'

import './BackendSelect.scss'

type Props = {
  backend: Backend | null,
  backends: Backend[],
  onCreateNewBackend: () => void,
  error?: string,
  searchPlaceholder?: string,
  onSelect: (arg1: Backend | null) => void
};

const BackendSelect = (
  {
    backend,
    backends,
    onSelect,
    onCreateNewBackend,
    searchPlaceholder,
    error,
  }: Props,
): React.ReactElement => {
  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'Private Base URL', propName: 'privateEndpoint' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <>
      {/* $FlowFixMe[prop-missing] Implement async pagination */}
      <SelectWithModal
        label="Backend"
        fieldId="backend_api_config_backend_api_id"
        id="backend_api_config_backend_api_id"
        name="backend_api_config[backend_api_id]"
        // $FlowIssue[incompatible-type] backend is compatible with null
        item={backend}
        items={backends.map(b => ({ ...b, description: b.privateEndpoint }))}
        itemsCount={backends.length}
        cells={cells}
        // $FlowIssue[incompatible-type] It should not complain since Record.id has union "number | string"
        onSelect={onSelect}
        header="Recently created backends"
        title="Select a backend"
        placeholder="Select a backend"
        footerLabel="View all backends"
        searchPlaceholder={searchPlaceholder}
        helperTextInvalid={error}
      />
      <Button
        variant="link"
        icon={<PlusCircleIcon />}
        onClick={onCreateNewBackend}
        data-testid="newBackendCreateBackend-buttonLink"
        className="pf-c-button__as-hint"
      >
        Create a backend
      </Button>
    </>
  )
}
export { BackendSelect }
