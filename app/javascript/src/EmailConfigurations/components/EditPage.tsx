import {
  Card,
  CardBody,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { EmailConfigurationForm } from 'EmailConfigurations/components/EmailConfigurationForm'

import type { FunctionComponent } from 'react'
import type { FormEmailConfiguration, FormErrors } from 'EmailConfigurations/types'

import './EditPage.scss'

interface Props {
  url: string;
  emailConfiguration: FormEmailConfiguration;
  errors?: FormErrors;
}

const EditPage: FunctionComponent<Props> = ({
  url,
  emailConfiguration,
  errors
}) => (
  <>
    <PageSection variant={PageSectionVariants.light}>
      <h1>Edit email configuration</h1>
    </PageSection>

    <PageSection>
      <Card>
        <CardBody>
          <EmailConfigurationForm
            isUpdate
            emailConfiguration={emailConfiguration}
            errors={errors}
            url={url}
          />
        </CardBody>
      </Card>
    </PageSection>
  </>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const EditPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<EditPage {...props} />, containerId) }

export { EditPage, EditPageWrapper, Props }
