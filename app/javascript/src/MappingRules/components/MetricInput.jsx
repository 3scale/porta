// @flow

import * as React from 'react'

import { FormGroup, Radio } from '@patternfly/react-core'
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
      label="Method or metric to increment"
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
          // $FlowFixMe[prop-missing] implement async pagination
          // $FlowIssue[incompatible-type-arg]
          <SelectWithModal
            label=""
            fieldId="proxy_rule_metric_id"
            id="proxy_rule_metric_id_select_method"
            name="proxy_rule[metric_id]"
            // $FlowIssue[incompatible-type] metrics can be null, that's the point
            item={metric}
            items={methods}
            itemsCount={methods.length}
            cells={cells}
            onSelect={handleOnSelect}
            header="Most recently created methods"
            title="Select a method"
            placeholder="Select a method"
            searchPlaceholder="Find a method"
            aria-label="Select a method"
            onToggle={setIsExpanded}
            isExpanded={isExpanded}
            footerLabel="View all methods"
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
          // $FlowFixMe[prop-missing] implement async pagination
          // $FlowIssue[incompatible-type-arg]
          <SelectWithModal
            label=""
            fieldId="proxy_rule_metric_id"
            id="proxy_rule_metric_id_select_metric"
            name="proxy_rule[metric_id]"
            // $FlowIssue[incompatible-type] metrics can be null, that's the point
            item={metric}
            items={topLevelMetrics}
            itemsCount={topLevelMetrics.length}
            cells={cells}
            onSelect={handleOnSelect}
            header="Most recently created metrics"
            title="Select a metric"
            placeholder="Select a metric"
            searchPlaceholder="Find a metric"
            aria-label="Select a metric"
            onToggle={setIsExpanded}
            isExpanded={isExpanded}
            footerLabel="View all metrics"
          />
        )}
      </div>
    </FormGroup>
  )
}

export { MetricInput }
