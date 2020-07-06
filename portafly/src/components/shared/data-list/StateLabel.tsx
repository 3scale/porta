import React from 'react'
import { Label, LabelProps } from '@patternfly/react-core'
import { TFunctionKeys } from 'i18next'
import { useTranslation } from 'i18n/useTranslation'
import { State } from 'types'

interface Props {
  state: State
}

const labelColorForState: Record<State, LabelProps['color']> = {
  approved: 'green',
  live: 'blue',
  rejected: 'grey',
  pending: 'orange',
  suspended: 'red'
}

const tKeyForState: Record<State, TFunctionKeys> = {
  approved: 'Approved',
  live: 'actions_filter_options.by_state_options.live',
  rejected: 'Rejected',
  pending: 'actions_filter_options.by_state_options.pending',
  suspended: 'actions_filter_options.by_state_options.suspended'
}

const StateLabel: React.FunctionComponent<Props> = ({ state }) => {
  // FIXME: states should be in shared.yml
  const { t } = useTranslation('applicationsIndex')
  const color = labelColorForState[state]
  const tKey = tKeyForState[state]

  return <Label variant="filled" color={color}>{t(tKey)}</Label>
}

export { StateLabel }
