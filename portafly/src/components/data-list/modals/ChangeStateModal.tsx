import React, { useState } from 'react'
import {
  Form,
  FormSelect,
  FormSelectOption,
  FormGroup
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { DataListModal, useDataListBulkActions, SubmitButton } from 'components/data-list'
import { changeState } from 'dal/accounts/bulkActions'
import { useAlertsContext } from 'components/util'

interface Props {
  items: string[]
}

const ChangeStateModal: React.FunctionComponent<Props> = ({
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

  const [value, setValue] = useState('')

  const onSubmit = () => {
    actionStart()
    changeState()
      .then(() => {
        actionSuccess()
        addAlert({ id: 'success', variant: 'success', title: t('toasts.change_state_start') })
      })
      .catch(() => {
        const error = t('toasts.change_state_error')
        console.error(error)
        actionFailed(error)
      })
  }

  const submitButton = (
    <SubmitButton
      key="submit"
      onClick={onSubmit}
      isDisabled={value === '' || isLoading}
    >
      {t('modals.change_state.send')}
    </SubmitButton>
  )

  const options = [
    { value: '', label: '' },
    { value: 'approved', label: t('states.approved') },
    { value: 'pending', label: t('states.pending') },
    { value: 'rejected', label: t('states.rejected') },
    { value: 'suspended', label: t('states.suspended') }
  ]

  return (
    <DataListModal
      title={t('modals.change_state.title')}
      submitButton={submitButton}
      items={items}
      to={t('modals.change_state.to')}
      errorMsg={errorMsg}
      shouldWarnClose={value !== ''}
    >
      <Form>
        <FormGroup
          label={t('modals.change_state.select_label')}
          type="string"
          helperText={t('modals.change_state.select_helper_text')}
          fieldId="state"
        >
          <FormSelect
            id="state"
            value={value}
            onChange={setValue}
            aria-label={t('aria-label-select')}
          >
            {options.map((option) => (
              <FormSelectOption key={option.value} value={option.value} label={option.label} />
            ))}
          </FormSelect>
        </FormGroup>
      </Form>
    </DataListModal>
  )
}

export { ChangeStateModal }
