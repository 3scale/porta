import React, { useState, useMemo } from 'react'
import {
  Text,
  TextListItem,
  Button,
  Modal,
  TextContent,
  TextList,
  Title,
  BaseSizes,
  Alert
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { useDataListBulkActions } from 'components/data-list'

import './dataListModal.scss'

interface Props {
  items: string[]
  title: string
  submitButton: JSX.Element
  to: string
  errorMsg?: string
}

const DataListModal: React.FunctionComponent<Props> = ({
  children,
  items,
  title,
  submitButton,
  to,
  errorMsg
}) => {
  const { t } = useTranslation('shared')
  const { closeModal } = useDataListBulkActions()

  const [isListCollapsed, setIsListCollapsed] = useState(items.length > 5)

  const onClose = () => {
    // eslint-disable-next-line no-alert
    if (window.confirm(t('modals.close_confirmation'))) {
      closeModal()
    }
  }

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

  const actions = [
    submitButton,
    <Button
      key="cancel"
      variant="link"
      onClick={onClose}
    >
      {t('modals.cancel')}
    </Button>
  ]

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
      {errorMsg && <Alert variant="warning" title={errorMsg} isInline />}
    </Modal>
  )
}

export { DataListModal }
