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
import { ServiceSelect } from 'ActiveDocs/components/ServiceSelect'
import { ApiJsonSpecInput } from 'ActiveDocs/components/ApiJsonSpecInput'
import { CSRFToken } from 'utilities/CSRFToken'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
import type { IRecord as Service } from 'Types'

import './ApiDocsForm.scss'

interface Props {
  name: string;
  systemName: string;
  published: boolean;
  serviceId?: number;
  collection?: Service[];
  description: string;
  apiJsonSpec: string;
  skipSwaggerValidations: boolean;
  url: string;
  errors: {
    name?: string[];
    body?: string[];
    systemName?: string[];
    description?: string[];
  };
}

const ApiDocsForm: FunctionComponent<Props> = ({
  name: defaultName,
  systemName: defaultSystemName,
  published: defaultPublished,
  serviceId: defaultServiceId,
  collection: defaultCollection,
  description: defaultdescription,
  apiJsonSpec: defaultApiJsonSpec,
  skipSwaggerValidations: defaultskipSwaggerValidations,
  url,
  errors
}) => {
  const [name, setName] = useState<string>(defaultName)
  const [systemName, setSystemName] = useState<string>(defaultSystemName)
  const [published, setPublished] = useState<boolean>(defaultPublished)
  const [description, setDescription] = useState(defaultdescription)
  const [apiJsonSpec, setApiJsonSpec] = useState(defaultApiJsonSpec)
  const [skipSwaggerValidations, setSkipSwaggerValidations] = useState(defaultskipSwaggerValidations)
  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- service, defaultCollection and defaultServiceId are always defined when isUpdate
  const [service, setService] = useState<Service>(defaultCollection!.find((s) => s.id === defaultServiceId)!)
  // const [loading, setLoading] = useState(false)

  console.log({ name, defaultName, errors, defaultCollection })

  // const isDisabled = !name // || !apiJsonSpec
  const isUpdate = defaultServiceId !== undefined

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
        {isUpdate && <input name="_method" type="hidden" value="put" />}

        <NameInput errors={errors.name} name={name} setName={setName} />

        <SystemNameInput errors={errors.systemName} isDisabled={defaultServiceId !== undefined} setSystemName={setSystemName} systemName={systemName} />

        <Checkbox 
          aria-label="Is Published"
          id="api_docs_service_published_input"
          isChecked={published}
          label="Publish?"
          name="api_docs_service[published]"
          onChange={setPublished}
        />

        <DescriptionInput description={description} errors={errors.description} setDescription={setDescription} />

        {isUpdate && defaultCollection && <ServiceSelect service={service} services={defaultCollection} setService={setService} />}

        <ApiJsonSpecInput apiJsonSpec={apiJsonSpec} errors={errors.body} setApiJsonSpec={setApiJsonSpec} />

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
            // isDisabled={isDisabled}
            type="submit"
            variant="primary"
          >
            { isUpdate ? 'Update spec' : 'Create spec' }
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ApiDocsFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ApiDocsForm {...props} />, containerId) }

export { ApiDocsForm, ApiDocsFormWrapper, Props }
