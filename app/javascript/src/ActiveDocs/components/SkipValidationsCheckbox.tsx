import { Checkbox, FormGroup } from '@patternfly/react-core'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import type { FunctionComponent } from 'react'

interface Props {
  errors?: string[];
  skipSwaggerValidations: boolean;
  setSkipSwaggerValidations: (name: boolean) => void;
}

const emptyArray = [] as never[]

const SkipValidationsCheckbox: FunctionComponent<Props> = ({
  errors = emptyArray,
  skipSwaggerValidations,
  setSkipSwaggerValidations
}) => {
  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      isRequired
      fieldId="api_docs_service_skip_swagger_validations"
      helperTextInvalid={errors}
      helperTextInvalidIcon={<ExclamationCircleIcon />}
      validated={validated}
    >
      <input name="api_docs_service[skip_swagger_validations]" type="hidden" value="0" />
      <Checkbox
        id="api_docs_service_skip_swagger_validations"
        isChecked={skipSwaggerValidations}
        label="Skip swagger validations"
        name="api_docs_service[skip_swagger_validations]"
        onChange={setSkipSwaggerValidations}
      />
    </FormGroup>
  )
}

export type { Props }
export { SkipValidationsCheckbox }
