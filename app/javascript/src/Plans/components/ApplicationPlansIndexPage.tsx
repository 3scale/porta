/* eslint-disable react/jsx-props-no-spreading */
import {
  PageSection,
  PageSectionVariants,
  Text,
  TextContent
} from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { IndexPageMainSection } from 'Plans/components/IndexPageMainSection'

import type { Props as MainSectionProps } from 'Plans/components/IndexPageMainSection'
import type { FunctionComponent } from 'react'

type Props = MainSectionProps

const ApplicationPlansIndexPage: FunctionComponent<Props> = ({
  defaultPlanSelectProps,
  plansTableProps
}) => (
  <>
    <PageSection variant={PageSectionVariants.light}>
      <TextContent>
        <Text component="h1">Application Plans</Text>
        <Text component="p">
          Application plans establish the rules (limits, pricing, features) for using your API;
          every developer&lsquo;s application accessing your API will be accessing it within the
          constraints of an application plan. From a business perspective, application plans allow
          you to target different audiences by using multiple plans, that is, basic, pro, premium,
          with different sets of rules.
        </Text>
      </TextContent>
    </PageSection>

    <IndexPageMainSection
      defaultPlanSelectProps={defaultPlanSelectProps}
      helperText={`If an application plan is set as default, 3scale sets this plan upon service
        subscription.`}
      plansTableProps={plansTableProps}
    />
  </>
)

const ApplicationPlansIndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ApplicationPlansIndexPage {...props} />, containerId) }

export type { Props }
export { ApplicationPlansIndexPage, ApplicationPlansIndexPageWrapper }
