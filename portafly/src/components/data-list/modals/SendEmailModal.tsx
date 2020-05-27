import React, { useState } from 'react'
import {
  Form,
  FormGroup,
  TextInput,
  TextArea
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { DataListModal, useDataListBulkActions, SubmitButton } from 'components/data-list'
import { sendEmail } from 'dal/accounts/bulkActions'
import { useAlertsContext } from 'components/util'

interface Props {
  items: string[]
}

const SendEmailModal: React.FunctionComponent<Props> = ({
  items
}) => {
  const { t } = useTranslation('shared')
  const { addAlert } = useAlertsContext()
  const {
    isLoading,
    errorMsg,
    actionStart,
    actionSuccess,
    actionFailed
  } = useDataListBulkActions()
  const [subject, setSubject] = useState('')
  const [body, setBody] = useState('')

  const isSendDisabled = subject.length === 0 || body.length === 0

  const onSubmit = () => {
    actionStart()
    sendEmail()
      .then(() => {
        actionSuccess()
        addAlert({ id: 'success', variant: 'success', title: t('toasts.send_email_start') })
      })
      .catch(() => {
        const error = t('toasts.send_email_error')
        actionFailed(error)
      })
  }

  const submitButton = (
    <SubmitButton
      key="submit"
      onClick={onSubmit}
      isDisabled={isSendDisabled || isLoading}
    >
      {t('modals.send_email.send')}
    </SubmitButton>
  )

  return (
    <DataListModal
      title={t('modals.send_email.title')}
      submitButton={submitButton}
      items={items}
      to={t('modals.send_email.to')}
      errorMsg={errorMsg}
    >
      <Form>
        <FormGroup
          isRequired
          label={t('modals.send_email.subject')}
          fieldId="subject"
        >
          <TextInput
            isDisabled={isLoading}
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
            disabled={isLoading}
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
