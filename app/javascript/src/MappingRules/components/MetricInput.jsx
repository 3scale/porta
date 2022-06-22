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

type RadioOptionProps = {
  type: "metric" | "method",
  label: string,
  items: Array<Metric>
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

  const RadioOption = ({ type, label, items }: RadioOptionProps): React.Node => (
    <div id={`wrapper_${type}`}>
      <Radio
        isChecked={checked === type}
        name="radio-1"
        onChange={() => handleOnRadioChange(type)}
        label={label}
        id={`proxy_rule_metric_id_radio_${type}`}
      />
      {checked === type && (
        // $FlowFixMe[prop-missing] implement async pagination
        // $FlowIssue[incompatible-type-arg]
        <SelectWithModal
          label=""
          fieldId="proxy_rule_metric_id"
          id={`proxy_rule_metric_id_select_${type}`}
          name="proxy_rule[metric_id]"
          // $FlowIssue[incompatible-type] metrics can be null, that's the point
          item={metric}
          items={items}
          itemsCount={items.length}
          cells={cells}
          onSelect={handleOnSelect}
          header={`Most recently created ${type}s`}
          title={`Select a ${type}`}
          placeholder={`Select a ${type}`}
          searchPlaceholder={`Find a ${type}`}
          aria-label={`Select a ${type}`}
          onToggle={setIsExpanded}
          isExpanded={isExpanded}
          footerLabel={`View all ${type}s`}
        />
      )}
    </div>
  )

  return (
    <FormGroup
      isRequired
      label="Method or metric to increment"
      validated="default"
      fieldId="proxy_rule_metric_id"
    >
      <RadioOption
        type="method"
        label="Method"
        items={methods}
      />
      <RadioOption
        type="metric"
        label="Metric"
        items={topLevelMetrics}
      />
    </FormGroup>
  )
}

export { MetricInput }
