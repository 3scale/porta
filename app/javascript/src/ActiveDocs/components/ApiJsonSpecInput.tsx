import { FormGroup, TextArea } from '@patternfly/react-core'
// import { ExclamationCircleIcon } from '@patternfly/react-icons' add the icon when we upgrade to PF4
import { useEffect } from 'react'

import type { FunctionComponent } from 'react'
import type { Editor } from 'codemirror'

import './ApiJsonSpecInput.scss'

interface Props {
  apiJsonSpec: string;
  setApiJsonSpec: (description: string) => void;
  errors?: string[];
}

const ApiJsonSpecInput: FunctionComponent<Props> = ({
  apiJsonSpec,
  setApiJsonSpec,
  errors = []
}) => {
  
  const validated = errors.length ? 'error' : 'default'

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- We're sure this is safe
    const textarea = document.getElementById('api_docs_service_body')! as HTMLTextAreaElement
    const editor = window.CodeMirror.fromTextArea(textarea, {
      // @ts-expect-error TS is complaining, TODO: check @types/codemirror version so it matches with codemirror version
      matchBrackets: true,
      autoCloseBrackets: true,
      mode: 'application/json',
      lineWrapping: true,
      lineNumbers: true,
      theme: 'neat'
    })
    editor.setValue(apiJsonSpec)
    editor.on('change', (instance: Editor): void => { setApiJsonSpec(instance.getDoc().getValue()) })
  }, [])
  
  return (
    <FormGroup
      isRequired
      fieldId="api_docs_service_body"
      helperText="Specification must comply with Swagger 1.2 2.0 or 3.0."
      helperTextInvalid={errors}
      // helperTextInvalidIcon={<ExclamationCircleIcon />} add the icon when we upgrade to PF4
      label="API JSON Spec"
      validated={validated}
    >
      <TextArea
        id="api_docs_service_body"
        name="api_docs_service[body]"
        validated={validated}
      />
    </FormGroup>
  )
}

export { ApiJsonSpecInput, Props }
