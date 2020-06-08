import React, { useState } from 'react'
import {
  Form,
  FormSelect,
  FormSelectOption,
  FormGroup
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import {
  DataListModal,
  useDataListBulkActions,
  SubmitButton,
  useAlertsContext
} from 'components'
import { changeState } from 'dal/accounts/bulkActions'
import { CategoryOption } from 'types'

interface Props {
  states: CategoryOption[],
  items: string[]
}

const ChangeStateModal: React.FunctionComponent<Props> = ({
  states,
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
        addAlert({ id: 'success', variant: 'success', title: t('toasts.change_state_success') })
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

  const options = [{ name: '', humanName: '' }, ...states]

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
            // FIXME: missing translation string
            aria-label={t('modals.change_state.aria_label')}
          >
            {options.map((option) => (
              <FormSelectOption key={option.name} value={option.name} label={option.humanName} />
            ))}
          </FormSelect>
        </FormGroup>
      </Form>
    </DataListModal>
  )
}

export { ChangeStateModal }
