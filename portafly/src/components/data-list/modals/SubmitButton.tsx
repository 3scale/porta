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
    <div className="portafly-submit-button">
      {isLoading
        ? <Spinner size="lg" />
        : (
          <Button
            className="pepe"
            variant="primary"
            onClick={onClick}
            isDisabled={isDisabled}
          >
            {children}
          </Button>
        )}
    </div>
  )
}

export { SubmitButton }
