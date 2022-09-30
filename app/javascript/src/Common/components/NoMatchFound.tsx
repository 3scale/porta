
import {
  Button,
  Title,
  EmptyState,
  EmptyStatePrimary,
  EmptyStateIcon,
  EmptyStateBody
} from '@patternfly/react-core'
import { SearchIcon } from '@patternfly/react-icons'

import './NoMatchFound.scss'

type Props = {
  onClearFiltersClick?: () => void
};

const NoMatchFound = (
  {
    onClearFiltersClick
  }: Props
): React.ReactElement => <EmptyState>
  <EmptyStateIcon icon={SearchIcon} />
  <Title size="lg" headingLevel="h4">
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

export { NoMatchFound, Props }
