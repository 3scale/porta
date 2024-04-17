import { useEffect, useState } from 'react'
import {
  BaseSizes,
  Modal,
  ModalVariant,
  Spinner,
  Title
} from '@patternfly/react-core'

import { NewBackendForm } from 'BackendApis/components/NewBackendForm'

import type { FunctionComponent } from 'react'
import type { Backend } from 'Types'
import type { Props as NewBackendFormProps } from 'BackendApis/components/NewBackendForm'

import './NewBackendModal.scss'

interface Props {
  backendsPath: string;
  isOpen?: boolean;
  onClose: () => void;
  onCreateBackend: (backend: Backend) => void;
}

const NewBackendModal: FunctionComponent<Props> = ({
  backendsPath,
  isOpen = false,
  onClose,
  onCreateBackend
}) => {
  const [isLoading, setIsLoading] = useState(false)
  const [errors, setErrors] = useState<NewBackendFormProps['errors']>()

  const handleOnAjaxComplete = (_event: unknown, xhr: { responseText: string }, status: string) => {
    setIsLoading(false)

    if (status === 'success') {
      onCreateBackend(JSON.parse(xhr.responseText) as Backend)
    } else if (status === 'error') {
      setErrors(JSON.parse(xhr.responseText) as NewBackendFormProps['errors'])
    }
  }

  useEffect(() => {
    // This events are triggered with rails-jquery, which is different from the one from node_modules
    window.$(document)
      .on('ajax:send', 'form#new_backend_api_config', () => { setIsLoading(true) })
      .on('ajax:complete', 'form#new_backend_api_config', handleOnAjaxComplete)

    // No need for useEffect cleanup
  }, [])

  const header = (
    <>
      <Title className="with-spinner" headingLevel="h1" id="new-backend-modal-title" size={BaseSizes['2xl']}>
        Create backend
      </Title>
      {isLoading && <Spinner className="pf-u-ml-md" size="md" />}
    </>
  )

  return (
    <Modal
      aria-labelledby="new-backend-modal-title"
      header={header}
      isOpen={isOpen}
      title="Create backend"
      variant={ModalVariant.small}
      onClose={onClose}
    >
      <NewBackendForm
        action={backendsPath}
        errors={errors}
        isLoading={isLoading}
        onCancel={onClose}
      />
    </Modal>
  )
}

export type { Props }
export { NewBackendModal }
