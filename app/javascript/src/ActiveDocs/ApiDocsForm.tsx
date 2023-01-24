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
  isUpdate: boolean;
}

const ApiDocsForm: FunctionComponent<Props> = ({
  name: defaultName,
  systemName: defaultSystemName,
  published: defaultPublished,
  serviceId: defaultServiceId,
  collection,
  description: defaultdescription,
  apiJsonSpec: defaultApiJsonSpec,
  skipSwaggerValidations: defaultSkipSwaggerValidations,
  url,
  errors,
  isUpdate
}) => {
  const [name, setName] = useState<string>(defaultName)
  const [systemName, setSystemName] = useState<string>(defaultSystemName)
  const [published, setPublished] = useState<boolean>(defaultPublished)
  const [description, setDescription] = useState(defaultdescription)
  const [apiJsonSpec, setApiJsonSpec] = useState(defaultApiJsonSpec)
  const [skipSwaggerValidations, setSkipSwaggerValidations] = useState(defaultSkipSwaggerValidations)
  const [service, setService] = useState<Service | undefined>(collection?.find((s) => s.id === defaultServiceId) ?? collection?.[0])

  const isDisabled = !name || !apiJsonSpec

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        acceptCharset="UTF-8"
        action={url}
        id="new_api_docs"
        method="post"
        // isWidthLimited TODO: use when available instead of hardcoded css
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓" />
        {isUpdate && <input name="_method" type="hidden" value="put" />}

        <NameInput errors={errors.name} name={name} setName={setName} />

        <SystemNameInput errors={errors.systemName} isDisabled={isUpdate} setSystemName={setSystemName} systemName={systemName} />

        <Checkbox 
          aria-label="Is Published"
          id="api_docs_service_published_input"
          isChecked={published}
          label="Publish?"
          name="api_docs_service[published]"
          onChange={setPublished}
        />

        <DescriptionInput description={description} errors={errors.description} setDescription={setDescription} />

        { collection && <ServiceSelect service={service} services={collection} setService={setService} />}

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
            isDisabled={isDisabled}
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
