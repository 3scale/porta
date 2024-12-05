import { useState, useMemo } from 'react'
import { Alert, CalendarMonth, FormGroup, FormSelect, FormSelectOption } from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent, FormEvent } from 'react'

import './ExpirationDatePicker.scss'

interface ExpirationItem {
  id: string;
  label: string;
  period: number; // In seconds
}

const collection: ExpirationItem[] = [
  { id: '7', label: '7 days', period: 7 },
  { id: '30', label: '30 days', period: 30 },
  { id: '60', label: '60 days', period: 60 },
  { id: '90', label: '90 days', period: 90 },
  { id: 'custom', label: 'Custom...', period: 0 },
  { id: 'no-exp', label: 'No expiration', period: 0 }
]

const dayMs = 60 * 60 * 24 * 1000

interface Props {
  id: string;
  label: string | null;
}

const ExpirationDatePicker: FunctionComponent<Props> = ({ id, label }) => {
  const [selectedItem, setSelectedItem] = useState(collection[0])
  const [pickedDate, setPickedDate] = useState(new Date())
  const fieldName = `human_${id}`
  const fieldLabel = label ?? 'Expires in'

  const fieldDate = useMemo(() => {
    if (selectedItem.period === 0) return null

    return new Date(new Date().getTime() + selectedItem.period * dayMs)
  }, [selectedItem])

  const fieldHint = useMemo(() => {
    if (!fieldDate) return

    const date = new Date(fieldDate)
    date.setHours(0, 0, 0, 0)

    return `The token will expire on ${date.toLocaleDateString()}`
  }, [fieldDate])

  const dateValue = useMemo(() => {
    let value = ''

    if (fieldDate) {
      value = fieldDate.toISOString()
    } else if (selectedItem.id === 'custom' ) {
      value = pickedDate.toISOString()
    }

    return value
  }, [fieldDate, selectedItem, pickedDate])

  const handleOnChange = (_value: string, event: FormEvent<HTMLSelectElement>) => {
    const value = (event.target as HTMLSelectElement).value
    const selected = collection.find(i => i.id === value) ?? null

    if (selected === null) return

    setSelectedItem(selected)
    setPickedDate(new Date())
  }

  return (
    <>
      <FormGroup
        isRequired
        fieldId={fieldName}
        label={fieldLabel}
      >
        <FormSelect
          className="pf-c-form-control-expiration"
          id={fieldName}
          value={selectedItem.id}
          onChange={handleOnChange}
        >
          {collection.map((item: ExpirationItem) => {
            return (
              <FormSelectOption
                key={item.id}
                label={item.label}
                value={item.id}
              />
            )
          })}
        </FormSelect>
        <span className="pf-c-form-control-expiration-hint">{fieldHint}</span>
      </FormGroup>
      <input id={id} name={id} type="hidden" value={dateValue} />
      {selectedItem.id === 'custom' && (
        <CalendarMonth className="pf-u-mt-md" date={pickedDate} onChange={setPickedDate} />
      )}
      {dateValue === '' && (
        <>
          <br />
          <Alert title="Expiration is recommended" variant="warning">
            It is strongly recommended that you set an expiration date for your token to help keep your information
            secure
          </Alert>
        </>
      )}
    </>
  )
}

const ExpirationDatePickerWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ExpirationDatePicker id={props.id} label={props.label} />, containerId) }

export type { ExpirationItem, Props }
export { ExpirationDatePicker, ExpirationDatePickerWrapper }
