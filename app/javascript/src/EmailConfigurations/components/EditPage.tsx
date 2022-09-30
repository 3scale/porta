
import {
  Card,
  CardBody,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { EmailConfigurationForm } from './EmailConfigurationForm'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FormEmailConfiguration, FormErrors } from 'EmailConfigurations/types'

import './EditPage.scss'

type Props = {
  url: string,
  emailConfiguration: FormEmailConfiguration,
  errors?: FormErrors
};

const EditPage = (
  {
    url,
    emailConfiguration,
    errors
  }: Props
): React.ReactElement => {
  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <h1>Edit email configuration</h1>
      </PageSection>

      <PageSection>
        <Card>
          <CardBody>
            <EmailConfigurationForm
              url={url}
              emailConfiguration={emailConfiguration}
              errors={errors}
              isUpdate
            />
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

const EditPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<EditPage {...props} />, containerId)

export { EditPage, EditPageWrapper, Props }
