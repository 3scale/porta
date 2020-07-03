import React from 'react'
import { Label, LabelProps } from '@patternfly/react-core'

interface Props {
  state: string
}

const labelColorForState: Record<string, LabelProps['color']> = {
  approved: 'green',
  live: 'blue',
  rejected: 'grey',
  pending: 'orange',
  suspended: 'red'
}

const StateLabel: React.FunctionComponent<Props> = ({ state }) => {
  const color = labelColorForState[state.toLowerCase()]

  return <Label variant="filled" color={color}>{state}</Label>
}

export { StateLabel }
