import { useState } from 'react'
import { FormGroup, Radio } from '@patternfly/react-core'
import { SelectWithModal } from 'Common/components/SelectWithModal'

import type { FunctionComponent } from 'react'
import type { Metric } from 'Types'

import './MetricInput.scss'

type Props = {
  metric: Metric | null,
  setMetric: (arg1: Metric | null) => void,
  topLevelMetrics: Array<Metric>,
  methods: Array<Metric>
}

type RadioOptionProps = {
  type: 'metric' | 'method',
  label: string,
  items: Array<Metric>
}

const MetricInput: FunctionComponent<Props> = ({
  metric,
  setMetric,
  topLevelMetrics,
  methods
}) => {
  const [checked, setChecked] = useState<RadioOptionProps['type']>('method')

  const handleOnRadioChange = (radio: RadioOptionProps['type']) => {
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

  // FIXME: fix these lint errors
  // eslint-disable-next-line react/no-multi-comp, react/no-unstable-nested-components
  const RadioOption: FunctionComponent<RadioOptionProps> = ({
    type,
    label,
    items
  }) => (
    <div id={`wrapper_${type}`}>
      <Radio
        id={`proxy_rule_metric_id_radio_${type}`}
        isChecked={checked === type}
        label={label}
        name="radio-1"
        onChange={() => handleOnRadioChange(type)}
      />
      {checked === type && (
        <SelectWithModal
          aria-label={`Select a ${type}`}
          cells={cells}
          footerLabel={`View all ${type}s`}
          header={`Most recently created ${type}s`}
          id={`proxy_rule_metric_id_select_${type}`}
          item={metric}
          items={items}
          itemsCount={items.length}
          label=""
          name="proxy_rule[metric_id]"
          placeholder={`Select a ${type}`}
          searchPlaceholder={`Find a ${type}`}
          title={`Select a ${type}`}
          onSelect={handleOnSelect}
        />
      )}
    </div>
  )

  return (
    <FormGroup
      isRequired
      fieldId="proxy_rule_metric_id"
      label="Method or metric to increment"
      validated="default"
    >
      <RadioOption
        items={methods}
        label="Method"
        type="method"
      />
      <RadioOption
        items={topLevelMetrics}
        label="Metric"
        type="metric"
      />
    </FormGroup>
  )
}

export { MetricInput, Props }
