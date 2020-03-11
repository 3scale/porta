import React from 'react'
import {
  Title,
  EmptyState,
  EmptyStateVariant,
  EmptyStateIcon,
} from '@patternfly/react-core'
import { CubesIcon } from '@patternfly/react-icons'

export interface ISimpleEmptyStateProps {
  msg: string
}

const SimpleEmptyState: React.FunctionComponent<ISimpleEmptyStateProps> = ({ msg }) => (
  <EmptyState variant={EmptyStateVariant.full}>
    <EmptyStateIcon icon={CubesIcon} />
    <Title headingLevel="h5" size="lg">
      {msg}
    </Title>
  </EmptyState>
)

export { SimpleEmptyState }
