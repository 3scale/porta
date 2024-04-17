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
    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-explicit-any -- FIXME: jQuery used here is 1.8.2 but in our node_modules is 3.5
    ($ as any)(document)
      // TODO: jquery-ujs is deprecated, in rails 5 we should use rails-ujs. However, the former is broadly used so it's not trivial.
      .on('ajax:send', 'form#new_backend_api_config', () => { setIsLoading(true) })
      .on('ajax:complete', 'form#new_backend_api_config', handleOnAjaxComplete)
    // No need for cleanup
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
