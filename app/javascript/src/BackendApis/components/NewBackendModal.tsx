import { useEffect, useState } from 'react'
import {
  BaseSizes,
  Modal,
  Spinner,
  Title,
  TitleLevel
} from '@patternfly/react-core'
import { NewBackendForm } from 'BackendApis/components/NewBackendForm'

import type { FunctionComponent } from 'react'
import type { Backend } from 'Types'

import './NewBackendModal.scss'

type Props = {
  backendsPath: string,
  isOpen?: boolean,
  onClose: () => void,
  onCreateBackend: (arg1: Backend) => void
}

const NewBackendModal: FunctionComponent<Props> = ({
  backendsPath,
  isOpen = false,
  onClose,
  onCreateBackend
}) => {
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

  useEffect(() => {
    const jq = $ as any // HACK: remove this after finding the right typings
    // eslint-disable-next-line no-console
    console.log('jQuery', $().jquery) // TODO: verify version of jquery and use .live or .on accordingly
    jq('form#new_backend_api_config')
      // TODO: jquery-ujs is deprecated, in rails 5 we should use rails-ujs. However, the former is broadly used so it's not trivial.
      .live('ajax:send', () => setIsLoading(true))
      .live('ajax:complete', handleOnAjaxComplete)
    // No need for cleanup
  }, [])

  const header = (
    <>
      <Title className="with-spinner" headingLevel={TitleLevel.h1} size={BaseSizes['2xl']}>
        Create backend
      </Title>
      {isLoading && <Spinner className="pf-u-ml-md" size="md" />}
    </>
  )

  return (
    <Modal
      isSmall
      header={header}
      isOpen={isOpen}
      title="Create backend"
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

export { NewBackendModal, Props }
