import React, { useState, useMemo } from 'react'
import {
  Text,
  TextListItem,
  Button,
  Modal,
  TextContent,
  TextList,
  Title,
  BaseSizes
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'

import './dataListModal.scss'

interface Props {
  onClose: () => void
  items: string[]
  title: string
  actions: any
  to: string
}

const DataListModal: React.FunctionComponent<Props> = ({
  children,
  onClose,
  items,
  title,
  actions,
  to
}) => {
  const { t } = useTranslation('shared')
  const [isListCollapsed, setIsListCollapsed] = useState(items.length > 5)

  const textListItems = useMemo(
    () => items.map((a) => <TextListItem key={a}>{a}</TextListItem>),
    [items]
  )

  const adminList = isListCollapsed ? (
    <>
      {textListItems.slice(0, 5)}
      <Button component="a" onClick={() => setIsListCollapsed(false)} variant="link">
        {t('modals.expand_list_button', { count: items.length - 5 })}
      </Button>
    </>
  ) : textListItems

  const header = (
    <Title headingLevel="h1" size={BaseSizes['2xl']}>
      {title}
    </Title>
  )

  return (
    <Modal
      className="data-list-base-modal"
      width="44%"
      header={header}
      onClose={onClose}
      actions={actions}
      isOpen
    >
      <TextContent>
        <Text>{to}</Text>
        <TextList>
          {adminList}
        </TextList>
      </TextContent>
      {children}
    </Modal>
  )
}

export { DataListModal }
