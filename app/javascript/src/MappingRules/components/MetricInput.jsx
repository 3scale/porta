// @flow

import * as React from 'react'

import {
  FormGroup,
  SelectVariant,
  Radio
} from '@patternfly/react-core'
import { SelectWithModal } from 'Common'

import type { Metric } from 'Types'

import './MetricInput.scss'

type Props = {
  metric: Metric,
  setMetric: (Metric | null) => void,
  topLevelMetrics: Array<Metric>,
  methods: Array<Metric>
}

const MetricInput = ({ metric, setMetric, topLevelMetrics, methods }: Props): React.Node => {
  const [checked, setChecked] = React.useState<'method' | 'metric'>('method')
  const [isExpanded, setIsExpanded] = React.useState(false)

  const handleOnRadioChange = (radio) => {
    setChecked(radio)
    handleOnSelect(null)
  }

  const handleOnSelect = (metric: Metric | null) => {
    setIsExpanded(false)
    setMetric(metric)
  }

  const cells = [
    { title: 'Name', propName: 'name' },
    { title: 'System name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  return (
    <FormGroup
      isRequired
      label="Method or Metric to increment"
      validated="default"
      fieldId="proxy_rule_metric_id"
    >
      <div id="wrapper_method">
        <Radio
          isChecked={checked === 'method'}
          name="radio-1"
          onChange={() => handleOnRadioChange('method')}
          label="Method"
          id="proxy_rule_metric_id_radio_method"
        />
        {checked === 'method' && (
          // $FlowIssue[prop-missing]
          // $FlowIssue[incompatible-type-arg]
          <SelectWithModal
            cells={cells}
            id="proxy_rule_metric_id_select_method"
            variant={SelectVariant.single}
            aria-label="Select a method"
            onToggle={setIsExpanded}
            onSelect={handleOnSelect}
            // $FlowIssue[incompatible-type] metrics can be null, that's the point
            item={metric}
            items={methods}
            isExpanded={isExpanded}
            label=""
            modalTitle="Select a method"
            name="proxy_rule[metric_id]"
          />
        )}
      </div>
      <div id="wrapper_metric">
        <Radio
          isChecked={checked === 'metric'}
          name="radio-1"
          onChange={() => handleOnRadioChange('metric')}
          label="Metric"
          id="proxy_rule_metric_id_radio_metric"
        />
        {checked === 'metric' && (
          // $FlowIssue[prop-missing]
          // $FlowIssue[incompatible-type-arg]
          <SelectWithModal
            cells={cells}
            id="proxy_rule_metric_id_select_metric"
            variant={SelectVariant.single}
            aria-label="Select a metric"
            onToggle={setIsExpanded}
            onSelect={handleOnSelect}
            // $FlowIssue[incompatible-type] metrics can be null, that's the point
            item={metric}
            items={topLevelMetrics}
            isExpanded={isExpanded}
            label=""
            modalTitle="Select a metric"
            name="proxy_rule[metric_id]"
          />
        )}
      </div>
    </FormGroup>
  )
}

export { MetricInput }
