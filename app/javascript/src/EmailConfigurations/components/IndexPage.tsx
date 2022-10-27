import {
  Card,
  PageSection,
  PageSectionVariants
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
      <h1>Email configurations</h1>
    </PageSection>

    <PageSection>
      <Card>
        <EmailConfigurationsTable
          emailConfigurations={emailConfigurations}
          emailConfigurationsCount={emailConfigurationsCount}
          newEmailConfigurationPath={newEmailConfigurationPath}
        />
      </Card>
    </PageSection>
  </div>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const IndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<IndexPage {...props} />, containerId) }

export { IndexPage, IndexPageWrapper, Props }
