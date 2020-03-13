import React from 'react'
import { Button, Modal } from '@patternfly/react-core'
import { useLocalization } from 'i18n'
import * as Locales from 'i18n/locales'

interface ModalProsp {
  isOpen: boolean,
  onClose: () => void
}

const ChangeLocaleModal = ({ isOpen, onClose }: ModalProsp) => {
  const { t, setLocale } = useLocalization('overview')

  const changeLocale = (locale: Locales.LOCALES) => {
    setLocale(locale)
    onClose()
  }

  return (
    <Modal
      title={t('confirm_modal_button.confirmation.heading')}
      isOpen={isOpen}
      onClose={onClose}
      actions={[
        <Button key="confirm" variant="primary" onClick={() => changeLocale(Locales.enUS)}>
          {t('confirm_modal_button.confirmation.confirm_button.label')}
        </Button>,
        <Button key="cancel" variant="link" onClick={() => changeLocale(Locales.jaJP)}>
          {t('confirm_modal_button.confirmation.cancel_button.label')}
        </Button>
      ]}
      isFooterLeftAligned
    >
      {t('confirm_modal_button.confirmation.content')}
    </Modal>
  )
}

export { ChangeLocaleModal }
