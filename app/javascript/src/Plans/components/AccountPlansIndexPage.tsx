/* eslint-disable react/jsx-props-no-spreading */
import {
  Alert,
  PageSection,
  PageSectionVariants,
  Stack,
  StackItem,
  Text,
  TextContent
} from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { IndexPageMainSection } from 'Plans/components/IndexPageMainSection'

import type { Props as MainSectionProps } from 'Plans/components/IndexPageMainSection'
import type { FunctionComponent } from 'react'

interface Props extends MainSectionProps {
  showNotice: boolean;
}

const AccountPlansIndexPage: FunctionComponent<Props> = ({
  showNotice,
  defaultPlanSelectProps,
  plansTableProps
}) => (
  <>
    <PageSection variant={PageSectionVariants.light}>
      <Stack hasGutter>
        <StackItem>
          <TextContent>
            <Text component="h1">Account plans</Text>
            <Text component="p">
              Account plans create &quot;tiers&quot; of usage within the developer portal, allowing you
              to distinguish between grades of support, content and other services partners at different
              levels receive.
            </Text>
          </TextContent>
        </StackItem>
        {showNotice && (
          <StackItem>
            <Alert
              isInline
              title={(<><strong>You have no published or default plan</strong>. Without at least one of those being present, users cannot sign up.</>)}
              variant="warning"
            />
          </StackItem>
        )}
      </Stack>
    </PageSection>

    <IndexPageMainSection
      defaultPlanSelectProps={defaultPlanSelectProps}
      plansTableProps={plansTableProps}
    />
  </>
)

const AccountPlansIndexPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<AccountPlansIndexPage {...props} />, containerId) }

export type { Props }
export { AccountPlansIndexPage, AccountPlansIndexPageWrapper }
