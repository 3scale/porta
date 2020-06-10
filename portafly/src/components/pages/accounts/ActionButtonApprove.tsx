import React, { useState } from 'react'
import { Button } from '@patternfly/react-core'
import { CheckIcon } from '@patternfly/react-icons'
import { useTranslation } from 'i18n/useTranslation'
import { approveAccount } from 'dal/accounts'
import { useAlertsContext } from 'components'

interface Props {
  id: string
}

const ActionButtonApprove: React.FunctionComponent<Props> = ({ id }) => {
  const { t } = useTranslation('accountsIndex')
  const { addAlert } = useAlertsContext()

  const [isDisabled, setIsDisabled] = useState(false)

  const onClick = () => {
    setIsDisabled(true)
    approveAccount(id)
      .then((res) => {
        console.log(res)
        addAlert({ id, title: 'Success', variant: 'success' })
      })
      .catch((err) => {
        console.log(err)
        addAlert({ id, title: 'Success', variant: 'danger' })
      })
      .finally(() => setIsDisabled(false))
  }

  return (
    <Button
      variant="link"
      icon={<CheckIcon />}
      onClick={onClick}
      isDisabled={isDisabled}
    >
      {t('accounts_table.actions_column_options.approve')}
    </Button>
  )
}

export { ActionButtonApprove }
