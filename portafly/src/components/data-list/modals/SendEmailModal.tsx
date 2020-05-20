import React, { useState } from 'react'
import {
  Button,
  Form,
  FormGroup,
  TextInput,
  TextArea
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { DataListModal } from 'components/data-list'

interface Props {
  items: string[]
  onClose: () => void
}

const SendEmailModal: React.FunctionComponent<Props> = ({
  onClose,
  items
}) => {
  const { t } = useTranslation('shared')

  const [subject, setSubject] = useState('')
  const [body, setBody] = useState('')

  const isSendDisabled = subject.length === 0 || body.length === 0

  const onSubmit = () => {
    onClose()
    // TODO: Implement actual submit
  }

  const actions = [
    <Button
      key="0"
      variant="primary"
      onClick={onSubmit}
      isDisabled={isSendDisabled}
    >
      {t('modals.send_email.send')}
    </Button>,
    <Button
      key="1"
      variant="link"
      onClick={onClose}
    >
      {t('modals.send_email.cancel')}
    </Button>
  ]

  return (
    <DataListModal
      title={t('modals.send_email.title')}
      onClose={onClose}
      actions={actions}
      items={items}
      to={t('modals.send_email.to')}
    >
      <Form>
        <FormGroup
          isRequired
          label={t('modals.send_email.subject')}
          fieldId="subject"
        >
          <TextInput
            isRequired
            type="text"
            id="subject"
            name="subject"
            aria-describedby="subject-helper"
            value={subject}
            onChange={setSubject}
          />
        </FormGroup>
        <FormGroup
          isRequired
          label={t('modals.send_email.body')}
          fieldId="body"
        >
          <TextArea
            isRequired
            id="body"
            name="body"
            aria-label="aria label"
            value={body}
            onChange={setBody}
          />
        </FormGroup>
      </Form>
    </DataListModal>
  )
}

export { SendEmailModal }
