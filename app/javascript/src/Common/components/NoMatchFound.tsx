import {
  Button,
  EmptyState,
  EmptyStateBody,
  EmptyStateIcon,
  EmptyStatePrimary,
  EmptyStateVariant,
  Title
} from '@patternfly/react-core'
import SearchIcon from '@patternfly/react-icons/dist/js/icons/search-icon'

import type { FunctionComponent } from 'react'

interface Props {
  onClearFiltersClick?: () => void;
}

const NoMatchFound: FunctionComponent<Props> = ({
  onClearFiltersClick
}) => (
  <EmptyState variant={EmptyStateVariant.large}>
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

export type { Props }
export { NoMatchFound }
