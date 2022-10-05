import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Form,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { CSRFToken } from 'utilities/CSRFToken'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { notice } from 'utilities/alert'
import { BackendSelect } from 'BackendApis/components/BackendSelect'
import { PathInput } from 'BackendApis/components/PathInput'
import { NewBackendModal } from 'BackendApis/components/NewBackendModal'

import type { FunctionComponent } from 'react'
import type { Backend } from 'Types'

import './AddBackendForm.scss'

type Props = {
  backend: Backend | null,
  backends: Backend[],
  url: string,
  inlineErrors: null | {
    // eslint-disable-next-line camelcase
    backend_api_id?: Array<string>,
    path?: Array<string>
  },
  backendsPath: string
}

const AddBackendForm: FunctionComponent<Props> = ({
  backend: initialBackend,
  backends,
  url,
  backendsPath,
  inlineErrors
}) => {
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
          acceptCharset="UTF-8"
          action={url}
          id="new_backend_api_config"
          method="post"
          onSubmit={() => setLoading(true)}
          // isWidthLimited TODO: use when available instead of hardcoded css
        >
          <CSRFToken />
          <input name="utf8" type="hidden" value="✓" />

          <BackendSelect
            backend={backend}
            backends={updatedBackends}
            error={inlineErrors ? inlineErrors.backend_api_id && inlineErrors.backend_api_id[0] : undefined}
            searchPlaceholder="Find a backend"
            onCreateNewBackend={() => setIsModalOpen(true)}
            onSelect={setBackend}
          />

          <PathInput
            error={inlineErrors ? inlineErrors.path && inlineErrors.path[0] : undefined}
            path={path}
            setPath={setPath}
          />

          <ActionGroup>
            <Button
              data-testid="addBackend-buttonSubmit"
              isDisabled={!isFormComplete || loading}
              type="submit"
              variant="primary"
            >
              Add to product
            </Button>
          </ActionGroup>
        </Form>
      </PageSection>

      <NewBackendModal
        backendsPath={backendsPath}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onCreateBackend={handleOnCreateBackend}
      />
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const AddBackendFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<AddBackendForm {...props} />, containerId)

export { AddBackendForm, AddBackendFormWrapper, Props }
