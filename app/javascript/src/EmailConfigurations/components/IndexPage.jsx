// @flow

import * as React from 'react'

import {
  Card,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { EmailConfigurationsTable } from './EmailConfigurationsTable'
import { createReactWrapper } from 'utilities'

import type { EmailConfiguration } from 'EmailConfigurations/types'

import './IndexPage.scss'

type Props = {
  emailConfigurations: EmailConfiguration[],
  emailConfigurationsCount: number,
  newEmailConfigurationPath: string
}

const IndexPage = ({
  emailConfigurations,
  emailConfigurationsCount,
  newEmailConfigurationPath
}: Props): React.Node => (
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

const IndexPageWrapper = (props: Props, containerId: string): void => createReactWrapper(<IndexPage {...props} />, containerId)

export { IndexPage, IndexPageWrapper }
