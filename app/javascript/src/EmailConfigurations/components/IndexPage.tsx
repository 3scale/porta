import {
  Card,
  CardBody,
  PageSection,
  PageSectionVariants,
  Text,
  TextContent
} from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { EmailConfigurationsTable } from 'EmailConfigurations/components/EmailConfigurationsTable'

import type { FunctionComponent } from 'react'
import type { EmailConfiguration } from 'EmailConfigurations/types'

import './IndexPage.scss'

interface Props {
  emailConfigurations: EmailConfiguration[];
  emailConfigurationsCount: number;
  newEmailConfigurationPath: string;
}

const IndexPage: FunctionComponent<Props> = ({
  emailConfigurations,
  emailConfigurationsCount,
  newEmailConfigurationPath
}) => (
  <div id="email-configurations-index-page">
    <PageSection variant={PageSectionVariants.light}>
      <TextContent>
        <Text component="h1">Email configurations</Text>
      </TextContent>
    </PageSection>

    <PageSection>
      <Card>
        <CardBody>
          <EmailConfigurationsTable
            emailConfigurations={emailConfigurations}
            emailConfigurationsCount={emailConfigurationsCount}
            newEmailConfigurationPath={newEmailConfigurationPath}
          />
        </CardBody>
      </Card>
    </PageSection>
  </div>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const IndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<IndexPage {...props} />, containerId) }

export type { Props }
export { IndexPage, IndexPageWrapper }
