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
import { BackendSelect, PathInput } from 'BackendApis'
import { CSRFToken } from 'utilities/utils'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Backend } from 'Types'

import './AddBackendForm.scss'

type Props = {
  backends: Backend[],
  url: string,
  newBackendPath: string
}

const AddBackendForm = ({ backends, url, newBackendPath }: Props): React.Node => {
  const [backend, setBackend] = useState<Backend | null>(null)
  const [path, setPath] = useState('')
  const [loading, setLoading] = useState(false)

  const isFormComplete = backend !== null && path !== ''

  return (
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
          backends={backends}
          newBackendPath={newBackendPath}
          onSelect={setBackend}
        />

        <PathInput path={path} setPath={setPath} />

        <ActionGroup>
          <Button
            variant='primary'
            type='submit'
            isDisabled={!isFormComplete || loading}
            data-testid="submit"
          >
            Add to Product
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

const AddBackendFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<AddBackendForm {...props} />, containerId)

export { AddBackendForm, AddBackendFormWrapper }
