import React from 'react'

import { Button, Spinner } from '@patternfly/react-core'
import { useDataListBulkActions } from 'components/data-list'

import './submitButton.scss'

interface Props {
  onClick: () => void,
  isDisabled?: boolean
}

const SubmitButton: React.FunctionComponent<Props> = ({
  onClick,
  isDisabled,
  children
}) => {
  const { isLoading } = useDataListBulkActions()
  return (
    <Button
      className="portafly-submit-button"
      variant="primary"
      onClick={onClick}
      isDisabled={isDisabled}
    >
      {children}
      {isLoading && <Spinner size="md" />}
    </Button>
  )
}

export { SubmitButton }
