import { useState } from 'react'
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
  action: string;
  apiJsonSpec: string;
  collection?: Service[];
  description: string;
  errors: {
    body?: string[];
    description?: string[];
    name?: string[];
    systemName?: string[];
  };
  isUpdate: boolean;
  name: string;
  published: boolean;
  serviceId?: number;
  skipSwaggerValidations: boolean;
  systemName: string;
}

const ApiDocsForm: FunctionComponent<Props> = ({
  action,
  apiJsonSpec: defaultApiJsonSpec,
  collection,
  description: defaultdescription,
  errors,
  isUpdate,
  name: defaultName,
  published: defaultPublished,
  serviceId: defaultServiceId,
  skipSwaggerValidations: defaultSkipSwaggerValidations,
  systemName: defaultSystemName
}) => {
  const [apiJsonSpec, setApiJsonSpec] = useState(defaultApiJsonSpec)
  const [description, setDescription] = useState(defaultdescription)
  const [name, setName] = useState(defaultName)
  const [published, setPublished] = useState(defaultPublished)
  const [service, setService] = useState(collection?.find((s) => s.id === defaultServiceId) ?? collection?.[0])
  const [skipSwaggerValidations, setSkipSwaggerValidations] = useState(defaultSkipSwaggerValidations)
  const [systemName, setSystemName] = useState(defaultSystemName)

  const isDisabled = !name || !apiJsonSpec

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        acceptCharset="UTF-8"
        action={action}
        method="post"
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓" />
        {isUpdate && <input name="_method" type="hidden" value="put" />}

        <NameInput errors={errors.name} name={name} setName={setName} />

        <SystemNameInput 
          errors={errors.systemName} 
          isDisabled={isUpdate} 
          setSystemName={setSystemName} 
          systemName={systemName} 
        />

        <Checkbox 
          id="api_docs_service_published_input"
          isChecked={published}
          label="Publish?"
          name="api_docs_service[published]"
          onChange={setPublished}
        />

        <DescriptionInput description={description} errors={errors.description} setDescription={setDescription} />

        {collection && <ServiceSelect service={service} services={collection} setService={setService} />}

        <ApiJsonSpecInput apiJsonSpec={apiJsonSpec} errors={errors.body} setApiJsonSpec={setApiJsonSpec} />

        <Checkbox 
          id="api_docs_service_skip_swagger_validations"
          isChecked={skipSwaggerValidations}
          label="Skip swagger validations"
          name="api_docs_service[skip_swagger_validations]"
          onChange={setSkipSwaggerValidations}
        />

        <ActionGroup>
          <Button isDisabled={isDisabled} type="submit" variant="primary">
            {isUpdate ? 'Update spec' : 'Create spec'}
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ApiDocsFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ApiDocsForm {...props} />, containerId) }

export { ApiDocsForm, ApiDocsFormWrapper, Props }
