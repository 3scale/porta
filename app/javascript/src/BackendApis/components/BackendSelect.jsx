// @flow

import React, { useState } from 'react'

import {
  Button,
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import { PlusCircleIcon } from '@patternfly/react-icons'
import { toSelectOption, toSelectOptionObject, SelectOptionObject } from 'utilities/patternfly-utils'

import type { Backend } from 'Types'

const HEADER = { id: 'header', name: 'Most recently created Backends', disabled: true, className: 'pf-c-select__menu-item--group-name' }
const SHOW_ALL = { id: 'foo', name: 'View all Backends' }

 type Props = {
   backend: Backend | null,
   backends: Backend[],
   newBackendPath: string,
   onSelect: (Backend | null) => void,
   onShowAll: () => void,
   isDisabled?: boolean
 }

const MAX_PRODUCTS = 20

const BackendSelect = ({ isDisabled = false, newBackendPath, onSelect, onShowAll, backends, backend }: Props) => {
  const [expanded, setExpanded] = useState(false)

  const handleOnSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    if (option.id === SHOW_ALL.id) {
      onShowAll()
    } else {
      const selectedBackend = backends.find(b => String(b.id) === option.id)

      if (selectedBackend) {
        onSelect(selectedBackend)
      }
    }
  }

  return (
    <FormGroup
      isRequired
      label="Backend"
      fieldId="backend"
      helperText={(
        <p className="hint">
          <Button variant="link" icon={<PlusCircleIcon />} component="a" href={newBackendPath} isInline>
            Create new Backend
          </Button>
        </p>
      )}
    >
      {backend && <input type="hidden" name="backend_api_config[backend_api_id]" value={backend.id} />}
      <Select
        variant={SelectVariant.typeahead}
        placeholderText="Select a backend"
        // $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
        selections={backend && toSelectOptionObject(backend)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleOnSelect}
        isExpanded={expanded}
        isDisabled={isDisabled}
        onClear={() => onSelect(null)}
        aria-labelledby="backend"
        className="pf-c-select__menu--with-fixed-link"
      >
        {[HEADER, ...backends.slice(0, MAX_PRODUCTS), SHOW_ALL].map(b => toSelectOption({
          ...b,
          description: b.privateEndpoint || undefined
        }))}
      </Select>
    </FormGroup>
  )
}
export { BackendSelect }
