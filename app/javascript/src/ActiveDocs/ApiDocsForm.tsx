import { useState } from 'react'
import {
  ActionGroup,
  Button,
  Card,
  CardBody,
  Form,
  PageSection,
  PageSectionVariants,
  Text,
  TextContent
} from '@patternfly/react-core'

import { NameInput } from 'ActiveDocs/components/NameInput'
import { SystemNameInput } from 'ActiveDocs/components/SystemNameInput'
import { DescriptionInput } from 'ActiveDocs/components/DescriptionInput'
import { ServiceSelect } from 'ActiveDocs/components/ServiceSelect'
import { ApiJsonSpecInput } from 'ActiveDocs/components/ApiJsonSpecInput'
import { CSRFToken } from 'utilities/CSRFToken'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { PublishedCheckbox } from 'ActiveDocs/components/PublishedCheckbox'
import { SkipValidationsCheckbox } from 'ActiveDocs/components/SkipValidationsCheckbox'

import type { FunctionComponent } from 'react'
import type { IRecord as Service } from 'Types'

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
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">ActiveDocs</Text>
        </TextContent>
      </PageSection>

      <PageSection>
        <Card>
          <CardBody>
            <Form
              isWidthLimited
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

              <PublishedCheckbox published={published} setPublished={setPublished} />

              <DescriptionInput description={description} errors={errors.description} setDescription={setDescription} />

              {collection && <ServiceSelect service={service} services={collection} setService={setService} />}

              <ApiJsonSpecInput apiJsonSpec={apiJsonSpec} errors={errors.body} setApiJsonSpec={setApiJsonSpec} />

              <SkipValidationsCheckbox setSkipSwaggerValidations={setSkipSwaggerValidations} skipSwaggerValidations={skipSwaggerValidations} />

              <ActionGroup>
                <Button isDisabled={isDisabled} type="submit" variant="primary">
                  {isUpdate ? 'Update spec' : 'Create spec'}
                </Button>
              </ActionGroup>
            </Form>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ApiDocsFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ApiDocsForm {...props} />, containerId) }

export type { Props }
export { ApiDocsForm, ApiDocsFormWrapper }
