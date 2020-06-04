import React, { useState } from 'react'
import {
  Dropdown,
  DropdownToggle,
  DropdownToggleCheckbox,
  DropdownItem
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import {
  useDataListTable,
  useDataListPagination,
  useDataListFilters,
  filterRows
} from 'components'

const BulkSelectorWidget: React.FunctionComponent = () => {
  const { t } = useTranslation('shared')
  const {
    rows, columns,
    selectPage, selectAll, selectedRows
  } = useDataListTable()
  const { startIdx, endIdx } = useDataListPagination()
  const { filters } = useDataListFilters()

  const [isOpen, setIsOpen] = useState(false)

  const selectedCount = selectedRows.length
  const filteredRows = filterRows(rows, filters, columns)
  const pageRows = filteredRows.slice(startIdx, endIdx)
  const pageCount = pageRows.length
  const allCount = filteredRows.length

  const onSelect = () => setIsOpen((current) => !current)

  // FIXME: Setting isChecked null creates an error in the console for uncontrolled React prop
  // eslint-disable-next-line no-nested-ternary
  const isChecked = (selectedCount === 0) ? false
    : (selectedCount === allCount) ? true
    // For the indeterminate state, PF React needs to be passed null
      : null

  const dropdownItems = [
    <DropdownItem key="0" onClick={() => selectAll(false)}>
      {t('bulk_selector.none')}
    </DropdownItem>,
    <DropdownItem key="1" onClick={() => selectPage(pageRows)}>
      {t('bulk_selector.page', { count: pageCount })}
    </DropdownItem>,
    <DropdownItem key="2" onClick={() => selectAll(true, filteredRows)}>
      {t('bulk_selector.all', { count: allCount })}
    </DropdownItem>
  ]

  return (
    <Dropdown
      id="data-list-bulk-selector-dropdown"
      isOpen={isOpen}
      dropdownItems={dropdownItems}
      onSelect={onSelect}
      toggle={(
        <DropdownToggle
          onToggle={setIsOpen}
          splitButtonItems={[
            <DropdownToggleCheckbox
              key="data-list-bulk-selector-checkbox"
              id="data-list-bulk-selector-checkbox"
              isChecked={isChecked}
              onClick={() => selectAll(selectedCount === 0, filteredRows)}
              aria-label={t('bulk_selector.toggle_checkbox_aria_label')}
            />
          ]}
        >
          {selectedCount > 0 ? t('bulk_selector.label', { selectedCount }) : ''}
        </DropdownToggle>
      )}
    />
  )
}

export { BulkSelectorWidget }
