// @flow

import * as React from 'react'
import { useState } from 'react'

import {
  Form,
  ActionGroup,
  Button,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { BackendSelect, PathInput, NewBackendModal } from 'BackendApis'
import { CSRFToken, createReactWrapper, notice } from 'utilities'

import type { Backend } from 'Types'

import './AddBackendForm.scss'

type Props = {
  backend: Backend | null,
  backends: Backend[],
  url: string,
  inlineErrors: null | {
    backend_api_id?: Array<string>,
    path?: Array<string>
  },
  backendsPath: string
}

const AddBackendForm = ({ backend: initialBackend, backends, url, backendsPath, inlineErrors }: Props): React.Node => {
  const [backend, setBackend] = useState<Backend | null>(initialBackend)
  const [updatedBackends, setUpdatedBackends] = useState(backends)
  const [path, setPath] = useState('')
  const [loading, setLoading] = useState(false)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const isFormComplete = backend !== null

  const handleOnCreateBackend = (backend: Backend) => {
    notice('Backend created')
    setIsModalOpen(false)
    setBackend(backend)
    setUpdatedBackends([backend, ...updatedBackends])
  }

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <Form
          id="new_backend_api_config"
          acceptCharset='UTF-8'
          method='post'
          action={url}
          onSubmit={e => setLoading(true)}
          // isWidthLimited TODO: use when available instead of hardcoded css
        >
          <CSRFToken />
          <input name='utf8' type='hidden' value='✓' />

          <BackendSelect
            backend={backend}
            backends={updatedBackends}
            onSelect={setBackend}
            onCreateNewBackend={() => setIsModalOpen(true)}
            error={inlineErrors ? inlineErrors.backend_api_id && inlineErrors.backend_api_id[0] : undefined}
          />

          <PathInput
            path={path}
            setPath={setPath}
            error={inlineErrors ? inlineErrors.path && inlineErrors.path[0] : undefined}
          />

          <ActionGroup>
            <Button
              variant='primary'
              type='submit'
              isDisabled={!isFormComplete || loading}
              data-testid="addBackend-buttonSubmit"
            >
              Add to product
            </Button>
          </ActionGroup>
        </Form>
      </PageSection>

      <NewBackendModal
        backendsPath={backendsPath}
        onClose={() => setIsModalOpen(false)}
        isOpen={isModalOpen}
        onCreateBackend={handleOnCreateBackend}
      />
    </>
  )
}

const AddBackendFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<AddBackendForm {...props} />, containerId)

export { AddBackendForm, AddBackendFormWrapper }
