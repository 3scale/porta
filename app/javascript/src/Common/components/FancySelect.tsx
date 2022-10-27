import { useState } from 'react'
import { FormGroup, Select, SelectVariant } from '@patternfly/react-core'

import { toSelectOption, toSelectOptionObject, handleOnFilter } from 'utilities/patternfly-utils'
import type { IRecord, SelectOptionObject, ISelectOption } from 'utilities/patternfly-utils'

import type { ReactElement } from 'react'
import type { SelectOptionObject as PFSelectOptionObject, SelectOptionProps } from '@patternfly/react-core'

import './FancySelect.scss'

interface Props<T extends IRecord> {
  item: T | undefined;
  items: T[];
  onSelect: (selected: T | null) => void;
  label: string;
  id: string;
  header: string;
  isDisabled?: boolean;
  name?: string;
  helperText?: React.ReactNode;
  helperTextInvalid?: string;
  placeholderText?: string;
  footer?: {
    label: string;
    onClick: () => void;
  };
}

const emptyItem = { id: -1, name: 'No results found', disabled: true, privateEndpoint: '' } as const
const FOOTER_ID = 'footer_id'

const FancySelect = <T extends IRecord>({
  item,
  items,
  onSelect,
  label,
  id,
  header,
  isDisabled,
  name,
  helperText,
  helperTextInvalid,
  placeholderText,
  footer
}: Props<T>): ReactElement => {
  const [expanded, setExpanded] = useState(false)

  const headerItem = { id: 'header', name: header, disabled: true, className: 'pf-c-select__menu-item--group-name' } as const
  // TODO: Remove after upgrading @patternfly/react-core, see https://www.patternfly.org/v4/components/select#view-more
  const footerItem = footer && { id: FOOTER_ID, name: footer.label, className: 'pf-c-select__menu-item--sticky-footer' }

  const handleOnSelect = (_e: unknown, _option: PFSelectOptionObject | string) => {
    setExpanded(false)

    const option = (_option as SelectOptionObject)

    if (option.id === FOOTER_ID) {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      footer!.onClick()
    } else {
      const selectedBackend = items.find(b => String(b.id) === option.id)

      if (selectedBackend) {
        onSelect(selectedBackend)
      }
    }
  }

  // TODO: seems like this function should be moved to patternfly-utils
  const getSelectOptionsForItems = (forItems: T[]): React.ReactElement<SelectOptionProps>[] => {
    const selectItems: ISelectOption[] = [headerItem]

    if (forItems.length === 0) {
      selectItems.push(emptyItem)
    } else {
      selectItems.push(...forItems.map(i => ({ ...i, className: 'pf-c-select__menu-item-description' })))
    }

    if (footerItem) {
      selectItems.push(footerItem)
    }

    return selectItems.map(toSelectOption)
  }

  return (
    <FormGroup
      isRequired
      fieldId={id}
      helperText={helperText}
      helperTextInvalid={helperTextInvalid}
      isValid={!helperTextInvalid}
      label={label}
    >
      {!!name && item && <input name={name} type="hidden" value={item.id} />}
      <Select
        isGrouped
        aria-labelledby={id}
        className={footer ? 'pf-c-select__menu--with-fixed-link' : undefined}
        isDisabled={isDisabled}
        isExpanded={expanded}
        placeholderText={placeholderText}
        selections={item && toSelectOptionObject(item)}
        variant={SelectVariant.typeahead}
        onClear={() => { onSelect(null) }}
        onFilter={handleOnFilter<T>(items, getSelectOptionsForItems)}
        onSelect={handleOnSelect}
        onToggle={() => { setExpanded(!expanded) }}
      >
        {getSelectOptionsForItems(items)}
      </Select>
    </FormGroup>
  )
}

export { FancySelect, Props }
