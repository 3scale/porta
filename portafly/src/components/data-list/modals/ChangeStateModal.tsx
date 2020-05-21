import React, { useState } from 'react'
import {
  Button,
  Form,
  FormSelect,
  FormSelectOption,
  FormGroup
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { DataListModal, useDataListBulkActions } from 'components/data-list'
import { changeState } from 'dal/accounts/bulkActions'
import { useAlertsContext } from 'components'

interface Props {
  onClose: () => void
  items: string[]
}

const ChangeStateModal: React.FunctionComponent<Props> = ({
  onClose,
  items
}) => {
  const { t } = useTranslation('shared')
  const { addAlert } = useAlertsContext()
  const {
    isLoading,
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
        actionFailed()
        addAlert({ id: 'error', variant: 'danger', title: t('toasts.change_state_error') })
      })
  }

  const actions = [
    <Button
      key="confirm"
      variant="primary"
      onClick={onSubmit}
      isDisabled={value === '' || isLoading}
    >
      {t('modals.change_state.send')}
    </Button>,
    <Button key="cancel" variant="link" onClick={onClose}>
      {t('modals.change_state.cancel')}
    </Button>
  ]

  const options = [
    { value: '', label: '' },
    { value: 'approved', label: t('state.approved') },
    { value: 'pending', label: t('state.pending') },
    { value: 'rejected', label: t('state.rejected') },
    { value: 'suspended', label: t('state.suspended') }
  ]

  return (
    <DataListModal
      title={t('modals.change_state.title')}
      onClose={onClose}
      actions={actions}
      items={items}
      to={t('modals.change_state.to')}
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
