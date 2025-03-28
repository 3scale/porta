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
import type { AJAXSuccessEvent, AJAXErrorEvent, AJAXBeforeEvent } from 'Types/rails-ujs'

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

  const handleAJAXBefore = (event: AJAXBeforeEvent) => {
    setIsLoading(true)

    event.stopPropagation() // Prevent ajax spinner from showing up
  }

  const handleAJAXSuccess = (event: AJAXSuccessEvent<Backend>) => {
    const [response] = event.detail

    onCreateBackend(response)
    setIsLoading(false)
  }

  const handleAJAXError = (event: AJAXErrorEvent<NewBackendFormProps['errors']>) => {
    const [response] = event.detail
    setErrors(response)
    setIsLoading(false)

    event.stopPropagation() // Prevent from calling error handler in ajaxEvents.ts
  }

  useEffect(() => {
    document.body.addEventListener('ajax:before', handleAJAXBefore)
    document.body.addEventListener('ajax:success', handleAJAXSuccess)
    document.body.addEventListener('ajax:error', handleAJAXError)

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
