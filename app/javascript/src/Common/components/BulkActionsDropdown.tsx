import { useState } from 'react'
import {
  Dropdown,
  DropdownItem,
  DropdownToggle
} from '@patternfly/react-core'

import type { FunctionComponent } from 'react'
import type { ButtonProps } from '@patternfly/react-core'

interface BulkAction {
  name: string;
  title: string;
  url: string;
  variant: ButtonProps['variant'];
}

interface Props {
  actions: BulkAction[];
  allSelected: boolean;
  isDisabled: boolean;
}

const jquery1 = window.$

const BulkActionsDropdown: FunctionComponent<Props> = ({ actions, allSelected, isDisabled }) => {
  const [actionsDropdownOpen, setActionsDropdownOpen] = useState(false)

  function generateHrefForColorbox (url: string) {
    // url address might already include some parameters
    const connector = url.includes('?') ? '&' : '?'

    if (allSelected) {
      return url.concat(connector, 'selected_total_entries=true')
    } else {
      // TODO: can we generate this data without reading the DOM? Using selectedItems as a prop
      return url.concat(connector, jquery1('table tbody .pf-c-table__check input:checked').serialize())
    }
  }

  const dropdownItems = actions.map(({ name, title, url }) => (
    <DropdownItem
      key={name}
      onClick={() => {
        jquery1.colorbox({
          title,
          href: generateHrefForColorbox(url)
        })
      }}
    >
      {name}
    </DropdownItem>
  ))

  return (
    <Dropdown
      dropdownItems={dropdownItems}
      id="bulk-operations"
      isOpen={actionsDropdownOpen}
      toggle={(
        <DropdownToggle
          isDisabled={isDisabled}
          toggleVariant="primary"
          onToggle={setActionsDropdownOpen}
        >
          Actions
        </DropdownToggle>
      )}
      onSelect={() => { setActionsDropdownOpen(false) }}
    />
  )
}

export type { Props, BulkAction }
export { BulkActionsDropdown }
