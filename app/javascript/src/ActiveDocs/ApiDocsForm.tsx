import { useState, useEffect } from 'react'
import {
  ActionGroup,
  Button,
  Checkbox,
  Form,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'

import { NameInput } from 'ActiveDocs/components/NameInput'
import { SystemNameInput } from 'ActiveDocs/components/SystemNameInput'
import { DescriptionInput } from 'ActiveDocs/components/DescriptionInput'
import { ServiceInput } from 'ActiveDocs/components/ServiceInput'
import { ApiJsonSpecInput } from 'ActiveDocs/components/ApiJsonSpecInput'
import { CSRFToken } from 'utilities/CSRFToken'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'

interface Props {
  name: string;
  systemName: string;
  isPublished: boolean;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  service?: { service_id: number };
  description: string;
  apiJsonSpec: string;
  skipSwaggerValidations: boolean;
  url: string;
}

const ApiDocsForm: FunctionComponent<Props> = ({
  name: defaultname,
  systemName: defaultsystemName,
  isPublished: defaultisPublished,
  service: defaultservice,
  description: defaultdescription,
  apiJsonSpec: defaultapiJsonSpec,
  skipSwaggerValidations: defaultskipSwaggerValidations,
  url
}) => {
  const [name, setName] = useState<string>(defaultname)
  const [systemName, setSystemName] = useState<string>(defaultsystemName)
  const [isPublished, setIsPublished] = useState<boolean>(defaultisPublished)
  // const [service, setService] = useState(defaultservice)
  const [description, setDescription] = useState(defaultdescription)
  const [apiJsonSpec, setApiJsonSpec] = useState(defaultapiJsonSpec)
  const [skipSwaggerValidations, setSkipSwaggerValidations] = useState(defaultskipSwaggerValidations)
  // const [loading, setLoading] = useState(false)

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
    $(textarea).on('change', function (){ editor.setValue(textarea.value) })
  }, [])

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        acceptCharset="UTF-8"
        action={url}
        id="new_api_docs"
        method="post"
        // onSubmit={() => { setLoading(true) }}
        // isWidthLimited TODO: use when available instead of hardcoded css
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓" />

        <NameInput name={name} setName={setName} />

        <SystemNameInput isDisabled={defaultservice !== undefined} setSystemName={setSystemName} systemName={systemName} />

        <Checkbox 
          aria-label="Is Published"
          id="api_docs_service_published_input"
          isChecked={isPublished}
          label="Publish?"
          name="api_docs_service[published]"
          onChange={setIsPublished}
        />

        <DescriptionInput description={description} setDescription={setDescription} />

        {/* <ServiceInput service={service} setService={setService} /> */}

        <ApiJsonSpecInput apiJsonSpec={apiJsonSpec} setApiJsonSpec={setApiJsonSpec} />

        <Checkbox 
          aria-label="Skip swagger validation"
          id="api_docs_service_skip_swagger_validations"
          isChecked={skipSwaggerValidations}
          label="Skip swagger validations"
          name="api_docs_service[skip_swagger_validations]"
          onChange={setSkipSwaggerValidations}
        />

        <ActionGroup>
          <Button
            // data-testid="newBackendCreateBackend-buttonSubmit"
            // isDisabled={validationErrors !== undefined || isLoading}
            type="submit"
            variant="primary"
          >
            { defaultservice === undefined ? 'Create spec' : 'Update spec' }
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ApiDocsFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ApiDocsForm {...props} />, containerId) }

export { ApiDocsForm, ApiDocsFormWrapper, Props }
