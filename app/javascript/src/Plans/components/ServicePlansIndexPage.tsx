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

const ServicePlansIndexPage: FunctionComponent<Props> = ({
  defaultPlanSelectProps,
  plansTableProps
}) => (
  <>
    <PageSection variant={PageSectionVariants.light}>
      <TextContent>
        <Text component="h1">Service plans</Text>
        <Text component="p">
          Service plans allow you to define grades of service for each of the services (APIs)
          available through your developer portal. The plans allow you to define pricing per
          service and features available.
        </Text>
      </TextContent>
    </PageSection>

    <IndexPageMainSection
      defaultPlanSelectProps={defaultPlanSelectProps}
      plansTableProps={plansTableProps}
    />
  </>
)

const ServicePlansIndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ServicePlansIndexPage {...props} />, containerId) }

export type { Props }
export { ServicePlansIndexPage, ServicePlansIndexPageWrapper }
