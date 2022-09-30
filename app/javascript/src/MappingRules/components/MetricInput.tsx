import { FunctionComponent, useState } from 'react'

import { FormGroup, Radio } from '@patternfly/react-core'
import { SelectWithModal } from 'Common'

import type { Metric } from 'Types'

import './MetricInput.scss'

type Props = {
  metric: Metric | null,
  setMetric: (arg1: Metric | null) => void,
  topLevelMetrics: Array<Metric>,
  methods: Array<Metric>
};

type RadioOptionProps = {
  type: 'metric' | 'method',
  label: string,
  items: Array<Metric>
};

const MetricInput: FunctionComponent<Props> = ({
  metric,
  setMetric,
  topLevelMetrics,
  methods
}) => {
  const [checked, setChecked] = useState<'method' | 'metric'>('method')

  const handleOnRadioChange = (radio: 'method' | 'metric') => {
    setChecked(radio)
    handleOnSelect(null)
  }

  const handleOnSelect = (metric: Metric | null) => {
    setMetric(metric)
  }

  const cells: { title: string, propName: keyof Metric }[] = [
    { title: 'Name', propName: 'name' },
    { title: 'System name', propName: 'systemName' },
    { title: 'Last updated', propName: 'updatedAt' }
  ]

  const RadioOption = (
    {
      type,
      label,
      items
    }: RadioOptionProps
  ): React.ReactElement => <div id={`wrapper_${type}`}>
    <Radio
      isChecked={checked === type}
      name="radio-1"
      onChange={() => handleOnRadioChange(type)}
      label={label}
      id={`proxy_rule_metric_id_radio_${type}`}
    />
    {checked === type && (
      <SelectWithModal
        label=""
        id={`proxy_rule_metric_id_select_${type}`}
        name="proxy_rule[metric_id]"
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
        footerLabel={`View all ${type}s`}
      />
    )}
  </div>

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

export { MetricInput, Props }
