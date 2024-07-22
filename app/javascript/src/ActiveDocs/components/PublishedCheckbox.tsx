import { Checkbox, FormGroup } from '@patternfly/react-core'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import type { FunctionComponent } from 'react'

interface Props {
  errors?: string[];
  published: boolean;
  setPublished: (name: boolean) => void;
}

const emptyArray = [] as never[]

const PublishedCheckbox: FunctionComponent<Props> = ({ errors = emptyArray, published, setPublished }) => {
  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      isRequired
      fieldId="api_docs_service_published"
      helperTextInvalid={errors}
      helperTextInvalidIcon={<ExclamationCircleIcon />}
      validated={validated}
    >
      <input name="api_docs_service[published]" type="hidden" value="0" />
      <Checkbox
        id="api_docs_service_published_input"
        isChecked={published}
        label="Publish?"
        name="api_docs_service[published]"
        onChange={setPublished}
      />
    </FormGroup>
  )
}

export type { Props }
export { PublishedCheckbox }
