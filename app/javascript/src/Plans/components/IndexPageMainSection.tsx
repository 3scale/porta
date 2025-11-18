import {
  PageSection,
  Flex,
  FlexItem,
  Card,
  CardBody,
  HelperText,
  HelperTextItem
} from '@patternfly/react-core'

import { DefaultPlanSelectCard } from 'Plans/components/DefaultPlanSelectCard'
import { PlansTable } from 'Plans/components/PlansTable'

import type { FunctionComponent } from 'react'
import type { Props as DefaultPlanSelectProps } from 'Plans/components/DefaultPlanSelectCard'
import type { Props as PlansTableProps } from 'Plans/components/PlansTable'

interface Props {
  defaultPlanSelectProps: DefaultPlanSelectProps;
  helperText?: string;
  plansTableProps: PlansTableProps;
}

const IndexPageMainSection: FunctionComponent<Props> = ({
  defaultPlanSelectProps,
  helperText,
  plansTableProps
}) => (
  <PageSection>
    <Flex direction={{ default: 'column' }}>
      <FlexItem flex={{ default: 'flex_1' }}>
        <Card>
          <CardBody>
            {/* eslint-disable-next-line react/jsx-props-no-spreading */}
            <DefaultPlanSelectCard {...defaultPlanSelectProps} />

            {/* Add helper text here and not select's FormGroup to not break flex */}
            {helperText && (
              <HelperText>
                <HelperTextItem>
                  {helperText}
                </HelperTextItem>
              </HelperText>
            )}
          </CardBody>
        </Card>
      </FlexItem>

      <FlexItem flex={{ default: 'flex_1' }}>
        <Card>
          {/* eslint-disable-next-line react/jsx-props-no-spreading */}
          <PlansTable {...plansTableProps} />
        </Card>
      </FlexItem>
    </Flex>
  </PageSection>
)

export type { Props }
export { IndexPageMainSection }
