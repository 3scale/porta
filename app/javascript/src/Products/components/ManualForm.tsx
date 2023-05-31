import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  TextArea,
  TextInput
} from '@patternfly/react-core'
import { useState } from 'react'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import { CSRFToken } from 'utilities/CSRFToken'

import type { FormProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'

interface Props extends FormProps {
  service: {
    name: string;
    // eslint-disable-next-line @typescript-eslint/naming-convention
    system_name: string;
    description: string;
    errors: {
      name?: string[];
      // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
      system_name?: string[];
      description?: string[];
    };
  };
}

const ManualForm: FunctionComponent<Props> = ({
  service,
  ...formProps
}) => {
  const [name, setName] = useState(service.name)
  const [systemName, setSystemName] = useState(service.system_name)
  const [description, setDescription] = useState(service.description)

  const { errors } = service
  const { disabled } = formProps

  return (
    <Form
      isWidthLimited
      acceptCharset="UTF-8"
      method="post"
      // eslint-disable-next-line react/jsx-props-no-spreading
      {...formProps}
    >
      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />

      <FormGroup
        fieldId="service_name"
        helperTextInvalid={errors.name?.join(', ')}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Name"
        validated={errors.name?.length ? 'error' : 'default'}
      >
        <TextInput
          id="service_name"
          maxLength={255}
          name="service[name]"
          type="text"
          value={name}
          onChange={setName}
        />
      </FormGroup>

      <FormGroup
        fieldId="service_system_name"
        helperTextInvalid={errors.system_name?.join(', ')}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="System name"
        validated={errors.system_name?.length ? 'error' : 'default'}
      >
        <TextInput
          id="service_system_name"
          maxLength={255}
          name="service[system_name]"
          type="text"
          value={systemName}
          onChange={setSystemName}
        />
      </FormGroup>

      <FormGroup
        fieldId="service_description"
        helperTextInvalid={errors.description?.join(', ')}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        label="Description"
        validated={errors.description?.length ? 'error' : 'default'}
      >
        <TextArea
          id="service_description"
          name="service[description]"
          rows={3}
          type="text"
          value={description}
          onChange={setDescription}
        />
      </FormGroup>

      <ActionGroup>
        <Button isDisabled={disabled} type="submit" variant="primary">
          Create Product
        </Button>
      </ActionGroup>
    </Form>
  )
}

export type { Props }
export { ManualForm }
