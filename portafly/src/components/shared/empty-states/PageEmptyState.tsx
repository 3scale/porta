import React from 'react'
import {
  EmptyState,
  EmptyStateIcon,
  Title,
  EmptyStateVariant
} from '@patternfly/react-core'
import { CubesIcon } from '@patternfly/react-icons'

interface Props {
  msg: string
}

const PageEmptyState: React.FunctionComponent<Props> = ({ msg }) => (
  <EmptyState variant={EmptyStateVariant.full}>
    <EmptyStateIcon icon={CubesIcon} />
    <Title headingLevel="h5" size="lg">
      {msg}
    </Title>
  </EmptyState>
)

export { PageEmptyState }
