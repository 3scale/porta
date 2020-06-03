import React from 'react'
import {
  Bullseye,
  EmptyState,
  EmptyStateIcon,
  Title,
  EmptyStateBody,
  EmptyStateVariant
} from '@patternfly/react-core'
import { SearchIcon } from '@patternfly/react-icons'

interface Props {
  title: string
  body: string
  button?: JSX.Element
}

const TableEmptyState: React.FunctionComponent<Props> = ({
  title,
  body,
  button
}) => (
  <Bullseye>
    <EmptyState variant={EmptyStateVariant.small}>
      <EmptyStateIcon icon={SearchIcon} />
      <Title headingLevel="h2" size="lg">
        {title}
      </Title>
      <EmptyStateBody>
        {body}
      </EmptyStateBody>
      {button}
    </EmptyState>
  </Bullseye>
)

export { TableEmptyState }
