import React from 'react'
import {
  Title,
  EmptyState,
  EmptyStateVariant,
  EmptyStateIcon,
  Bullseye,
  EmptyStateBody
} from '@patternfly/react-core'
import { CubesIcon, SearchIcon } from '@patternfly/react-icons'

export interface ISimpleEmptyStateProps {
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

interface ITableEmptyState {
  title: string
  body: string
  button?: JSX.Element
}

const TableEmptyState: React.FunctionComponent<ITableEmptyState> = ({
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

export { SimpleEmptyState, TableEmptyState }
