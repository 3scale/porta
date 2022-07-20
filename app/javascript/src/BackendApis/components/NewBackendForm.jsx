// @flow

import * as React from 'react'
import { useState } from 'react'

import { ActionGroup, Button, Form } from '@patternfly/react-core'
import validate from 'validate.js'
import {
  NameInput,
  SystemNameInput,
  DescriptionInput,
  PrivateEndpointInput
} from 'BackendApis'
import { CSRFToken } from 'utilities'

type Props = {
  action: string,
  onCancel: () => void,
  isLoading?: boolean,
  errors?: {
    private_endpoint: Array<string>
  }
}

const VALIDATION_CONSTRAINTS = {
  name: { presence: { allowEmpty: false } },
  // Regexp taken from app/lib/system_name.rb#L15
  systemName: { format: { pattern: /^(\w[\w\-/]+)?$/ } },
  // This does not mean to be exhaustive, let the server do the real validation
  privateEndpoint: { format: { pattern: /(https?|wss?):\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_+.~#?&//=]*)/ } }
}

const NewBackendForm = ({ action, onCancel, isLoading = false, errors = {} }: Props): React.Node => {
  const [name, setName] = useState('')
  const [systemName, setSystemName] = useState('')
  const [description, setDescription] = useState('')
  const [privateEndpoint, setPrivateEndpoint] = useState('')

  const validationErrors = validate({ name, systemName, privateEndpoint }, VALIDATION_CONSTRAINTS)

  return (
    <Form
      id="new_backend_api_config"
      acceptCharset="UTF-8"
      method="post"
      action={action}
      // isWidthLimited TODO: use when available instead of hardcoded css
      data-remote
    >
      <CSRFToken />
      <input name="utf8" type="hidden" value="✓" />

      <NameInput name={name} setName={setName} />
      <SystemNameInput systemName={systemName} setSystemName={setSystemName} />
      <DescriptionInput description={description} setDescription={setDescription} />
      <PrivateEndpointInput privateEndpoint={privateEndpoint} setPrivateEndpoint={setPrivateEndpoint} errors={errors.private_endpoint} />

      <ActionGroup>
        <Button
          variant="primary"
          type="submit"
          isDisabled={validationErrors !== undefined || isLoading}
          data-testid="newBackendCreateBackend-buttonSubmit"
        >
          Create backend
        </Button>
        <Button
          variant="secondary"
          type="button"
          data-testid="cancel"
          onClick={onCancel}
        >
          Cancel
        </Button>
      </ActionGroup>
    </Form>
  )
}

export { NewBackendForm }
