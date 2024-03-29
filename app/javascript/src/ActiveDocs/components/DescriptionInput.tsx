import { FormGroup, TextArea } from '@patternfly/react-core'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import type { FunctionComponent } from 'react'

interface Props {
  description: string;
  errors?: string[];
  setDescription: (description: string) => void;
}

const emptyArray = [] as never[]

const DescriptionInput: FunctionComponent<Props> = ({
  description,
  errors = emptyArray,
  setDescription
}) => {

  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      fieldId="api_docs_service_description"
      helperTextInvalid={errors}
      helperTextInvalidIcon={<ExclamationCircleIcon />}
      label="Description"
      validated={validated}
    >
      <TextArea
        id="api_docs_service_description"
        name="api_docs_service[description]"
        validated={validated}
        value={description}
        onChange={setDescription}
      />
    </FormGroup>
  )
}

export type { Props }
export { DescriptionInput }
