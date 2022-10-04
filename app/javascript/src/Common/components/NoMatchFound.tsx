import {
  Button,
  EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStatePrimary,
  Title
} from '@patternfly/react-core'
import { SearchIcon } from '@patternfly/react-icons'

import type { FunctionComponent } from 'react'

import './NoMatchFound.scss'

type Props = {
  onClearFiltersClick?: () => void
}

const NoMatchFound: FunctionComponent<Props> = ({
  onClearFiltersClick
}) => (
  <EmptyState>
    <EmptyStateIcon icon={SearchIcon} />
    <Title headingLevel="h4" size="lg">
      No results found
    </Title>
    <EmptyStateBody>
      No results match the filter criteria. Clear all filters to show results.
    </EmptyStateBody>
    {onClearFiltersClick && (
      <EmptyStatePrimary>
        <Button variant="link" onClick={onClearFiltersClick}>Clear all filters</Button>
      </EmptyStatePrimary>
    )}
  </EmptyState>
)

export { NoMatchFound, Props }
