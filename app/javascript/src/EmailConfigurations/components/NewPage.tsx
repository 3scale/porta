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

import './NewPage.scss'

type Props = {
  url: string,
  emailConfiguration: FormEmailConfiguration,
  errors?: FormErrors
}

const NewPage: FunctionComponent<Props> = ({
  url,
  emailConfiguration,
  errors
}) => (
  <>
    <PageSection variant={PageSectionVariants.light}>
      <h1>New email configuration</h1>
    </PageSection>

    <PageSection>
      <Card>
        <CardBody>
          <EmailConfigurationForm
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
const NewPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewPage {...props} />, containerId)

export { NewPage, NewPageWrapper, Props }
