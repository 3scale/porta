import * as React from 'react';
import { useState } from 'react'

import {
  BaseSizes,
  Modal,
  Spinner,
  Title,
  TitleLevel
} from '@patternfly/react-core'
import { NewBackendForm } from 'BackendApis'

import './NewBackendModal.scss'

import type { Backend } from 'Types'

type Props = {
  backendsPath: string,
  isOpen?: boolean,
  onClose: () => void,
  onCreateBackend: (arg1: Backend) => void
};

const NewBackendModal = (
  {
    backendsPath,
    isOpen = false,
    onClose,
    onCreateBackend,
  }: Props,
): React.ReactElement => {
  const [isLoading, setIsLoading] = useState(false)
  const [errors, setErrors] = useState()

  const handleOnAjaxComplete = (_event: any, xhr: {
    responseText: string
  }, status: string) => {
    setIsLoading(false)

    if (status === 'success') {
      const backend = JSON.parse(xhr.responseText)
      onCreateBackend(backend)
    } else if (status === 'error') {
      const errors = JSON.parse(xhr.responseText)
      setErrors(errors)
    }
  }

  React.useEffect(() => {
    $('form#new_backend_api_config')
      // $FlowFixMe[prop-missing] jquery-ujs is deprecated, in rails 5 we should use rails-ujs. However, the former is broadly used so it's not trivial.
      .live('ajax:send', () => setIsLoading(true))
      .live('ajax:complete', handleOnAjaxComplete)
    // No need for cleanup
  }, [])

  const header = (
    <React.Fragment>
      <Title headingLevel={TitleLevel.h1} size={BaseSizes['2xl']} className="with-spinner">
        Create backend
      </Title>
      {isLoading && <Spinner size='md' className='pf-u-ml-md' />}
    </React.Fragment>
  )

  return (
    <Modal
      isSmall
      title="Create backend"
      header={header}
      isOpen={isOpen}
      onClose={onClose}
    >
      <NewBackendForm
        action={backendsPath}
        onCancel={onClose}
        isLoading={isLoading}
        errors={errors}
      />
    </Modal>
  )
}

export { NewBackendModal }
