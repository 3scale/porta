import React, { useState, useMemo } from 'react'
import {
  Dropdown,
  DropdownToggle,
  DropdownItem,
  DropdownSeparator,
  Text,
  TextContent,
  TextVariants
} from '@patternfly/react-core'
import { WarningTriangleIcon } from '@patternfly/react-icons'
import { useTranslation } from 'i18n/useTranslation'
import { BulkAction, useDataListTable, useDataListBulkActions } from 'components'

interface Props {
  // TODO: take a second look to BulkAction types
  actions: Record<NonNullable<BulkAction>, string>
}

const BulkActionsWidget: React.FunctionComponent<Props> = ({
  actions
}) => {
  const { t } = useTranslation('shared')
  const { selectedRows } = useDataListTable()
  const { setModal } = useDataListBulkActions()
  const isDisabled = selectedRows.length === 0

  const [isOpen, setIsOpen] = useState(false)

  const toggle = (
    <DropdownToggle onToggle={setIsOpen} isPrimary>
      {t('bulk_actions.title')}
    </DropdownToggle>
  )

  const warning = [
    // FIXME: add styles to look like in mockup
    <DropdownItem key="-1" isDisabled>
      <TextContent>
        <WarningTriangleIcon />
        <Text component={TextVariants.small}>
          {t('bulk_actions.warning')}
        </Text>
      </TextContent>
    </DropdownItem>,
    <DropdownSeparator key="separator" />
  ]

  const dropdownItems = useMemo(() => [
    ...(isDisabled ? warning : []),
    ...Object.keys(actions).map((key) => (
      <DropdownItem
        key={key}
        component="button"
        isDisabled={isDisabled}
        onClick={() => setModal(key as BulkAction)}
      >
        {actions[key as NonNullable<BulkAction>]}
      </DropdownItem>
    ))
  ], [isDisabled])

  return (
    <Dropdown
      id="data-list-bulk-actions-dropdown"
      onSelect={() => setIsOpen(!isOpen)}
      toggle={toggle}
      isOpen={isOpen}
      dropdownItems={dropdownItems}
    />
  )
}

export { BulkActionsWidget }
