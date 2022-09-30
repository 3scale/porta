
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

const BackendSelect: React.FunctionComponent<Props> = ({
  backend,
  backends,
  onSelect,
  onCreateNewBackend,
  searchPlaceholder,
  error
}) => {
  const cells: { title: string, propName: keyof Backend }[] = [
    { title: 'Name', propName: 'name' },
    { title: 'Private Base URL', propName: 'privateEndpoint' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <>
      <SelectWithModal
        label="Backend"
        id="backend_api_config_backend_api_id"
        name="backend_api_config[backend_api_id]"
        item={backend}
        items={backends.map(b => ({ ...b, description: b.privateEndpoint }))}
        itemsCount={backends.length}
        cells={cells}
        onSelect={onSelect}
        header="Recently created backends"
        title="Select a backend"
        placeholder="Select a backend"
        footerLabel="View all backends"
        searchPlaceholder={searchPlaceholder}
        helperTextInvalid={error}
        // FIXME: add it or make it optional
        fetchItems={() => { throw new Error('Function not implemented.') }} />
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
export { BackendSelect, Props }
