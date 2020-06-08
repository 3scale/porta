import React, { useState } from 'react'
import {
  Form,
  FormGroup,
  TextInput,
  TextArea
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import {
  DataListModal,
  SubmitButton,
  useAlertsContext,
  useDataListBulkActions
} from 'components'
import { sendEmail } from 'dal/accounts/bulkActions'

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
        addAlert({ id: 'success', variant: 'success', title: t('toasts.send_email_success') })
      })
      .catch(() => {
        const error = t('toasts.send_email_error')
        console.error(error)
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
      shouldWarnClose={subject !== '' || body !== ''}
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
            // FIXME: missing translation string
            aria-describedby={t('modas.send_email.subject_input_aria_label')}
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
            // FIXME: missing translation string
            aria-label={t('modals.send_email.body_textarea_aria_label')}
            value={body}
            onChange={setBody}
          />
        </FormGroup>
      </Form>
    </DataListModal>
  )
}

export { SendEmailModal }
