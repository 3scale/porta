import { Button } from '@patternfly/react-core'
import { PlusCircleIcon } from '@patternfly/react-icons'

import { SelectWithModal } from 'Common/components/SelectWithModal'

import type { Props as SelectWithModalProps } from 'Common/components/SelectWithModal'
import type { Backend } from 'Types'

import './BackendSelect.scss'

interface Props {
  backend: Backend | null;
  backends: Backend[];
  onCreateNewBackend: () => void;
  error?: string;
  searchPlaceholder?: string;
  onSelect: (backend: Backend | null) => void;
}

const BackendSelect: React.FunctionComponent<Props> = ({
  backend,
  backends,
  onSelect,
  onCreateNewBackend,
  searchPlaceholder,
  error
}) => {
  const cells: SelectWithModalProps<Backend>['cells'] = [
    { title: 'Name', propName: 'name' },
    { title: 'Private Base URL', propName: 'privateEndpoint' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <>
      <SelectWithModal
        cells={cells}
        fetchItems={() => { throw new Error('Function not implemented.') }} // FIXME: add it or make it optional
        footerLabel="View all backends"
        header="Recently created backends"
        helperTextInvalid={error}
        id="backend_api_config_backend_api_id"
        item={backend}
        items={backends.map(b => ({ ...b, description: b.privateEndpoint }))}
        itemsCount={backends.length}
        label="Backend"
        name="backend_api_config[backend_api_id]"
        placeholder="Select a backend"
        searchPlaceholder={searchPlaceholder}
        title="Select a backend"
        onSelect={onSelect}
      />
      <Button
        className="pf-c-button__as-hint"
        data-testid="newBackendCreateBackend-buttonLink"
        icon={<PlusCircleIcon />}
        variant="link"
        onClick={onCreateNewBackend}
      >
        Create a backend
      </Button>
    </>
  )
}

export type { Props }
export { BackendSelect }
