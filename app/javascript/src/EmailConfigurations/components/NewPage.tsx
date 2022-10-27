import * as React from 'react'

import {
  Card,
  CardBody,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { EmailConfigurationForm } from './EmailConfigurationForm'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FormEmailConfiguration, FormErrors } from 'EmailConfigurations/types'

import './NewPage.scss'

type Props = {
  url: string,
  emailConfiguration: FormEmailConfiguration,
  errors?: FormErrors
};

const NewPage = (
  {
    url,
    emailConfiguration,
    errors
  }: Props
): React.ReactElement => {
  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <h1>New email configuration</h1>
      </PageSection>

      <PageSection>
        <Card>
          <CardBody>
            <EmailConfigurationForm
              url={url}
              emailConfiguration={emailConfiguration}
              errors={errors}
            />
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

const NewPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewPage {...props} />, containerId)

export { NewPage, NewPageWrapper }
