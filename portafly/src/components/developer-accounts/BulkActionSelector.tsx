import React, { useState } from 'react'
import {
  Dropdown,
  DropdownToggle,
  DropdownToggleCheckbox,
  DropdownItem
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'

interface IBulkSelector {
  onSelectAll: (selected: boolean) => void
  onSelectPage: (selected: boolean) => void
  pageCount: number,
  allCount: number,
  selectedCount: number
}

const BulkSelector: React.FunctionComponent<IBulkSelector> = ({
  pageCount,
  allCount,
  selectedCount
}) => {
  const { t } = useTranslation('accounts')

  const [isOpen, setIsOpen] = useState(false)

  const onSelect = () => {
    setIsOpen(false)
  }

  const onClick = () => {
    // TODO
  }

  // FIXME: null does not work as indeterminate state for DropdownToggleCheckbox (bug?)
  // Also setting isChecked null creates an error in the console for uncontrolled React prop.
  // true -> checked, null -> indeterminate, false -> unchecked
  const isChecked = allCount > 0 && selectedCount === allCount

  const dropdownItems = [
    <DropdownItem key="0" component="button" onClick={() => {}}>
      {t('accounts_table.data_toolbar.bulk_selector.none')}
    </DropdownItem>,
    <DropdownItem key="1" component="button" onClick={() => {}}>
      {t('accounts_table.data_toolbar.bulk_selector.page', { count: pageCount })}
    </DropdownItem>,
    <DropdownItem key="2" component="button" onClick={() => {}}>
      {t('accounts_table.data_toolbar.bulk_selector.all', { count: allCount })}
    </DropdownItem>
  ]

  const Toggle = () => (
    <DropdownToggle
      onToggle={() => setIsOpen(!isOpen)}
      splitButtonItems={[
        <DropdownToggleCheckbox
          data-testid="developer-accounts-bulk-checkbox"
          id="developer-accounts-bulk-checkbox"
          isChecked={isChecked}
          onClick={onClick}
          key="split-checkbox"
          aria-label="Select all"
        />
      ]}
    >
      {selectedCount > 0 && t('accounts_table.data_toolbar.bulk_selector.label', { selectedCount })}
    </DropdownToggle>
  )

  return (
    <Dropdown
      isOpen={isOpen}
      dropdownItems={dropdownItems}
      onSelect={onSelect}
      toggle={<Toggle />}
    />
  )
}

export { BulkSelector }
