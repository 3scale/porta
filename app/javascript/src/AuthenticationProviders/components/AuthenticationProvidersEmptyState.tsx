import React from 'react'
import {
  Title,
  Button,
  EmptyState,
  EmptyStateIcon,
  EmptyStateBody
} from '@patternfly/react-core'
import UserIcon from '@patternfly/react-icons/dist/esm/icons/user-icon'

interface Props {
  newHref: string;
}

const AuthenticationProvidersEmptyState: React.FC<Props> = ({ newHref }) => (
  <EmptyState>
    <EmptyStateIcon icon={UserIcon} />
    <Title headingLevel="h4" size="lg">
      No SSO integrations
    </Title>
    <EmptyStateBody>
      Choose a Single Sign-On (SSO) provider and create an integration to access the Admin Portal.
    </EmptyStateBody>
    <Button
      component="a"
      href={newHref}
      variant="primary"
    >
      Add a SSO integration
    </Button>
  </EmptyState>
)

export type { Props }
export { AuthenticationProvidersEmptyState }
