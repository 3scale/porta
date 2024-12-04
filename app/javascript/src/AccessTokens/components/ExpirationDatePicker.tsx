import { useState, useMemo } from 'react'
import { Alert, CalendarMonth, FormGroup, FormSelect, FormSelectOption } from '@patternfly/react-core'

import { createReactWrapper } from 'utilities/createReactWrapper'
import type { IRecord } from 'utilities/patternfly-utils'

import type { FunctionComponent, FormEvent } from 'react'

import './ExpirationDatePicker.scss'

interface ExpirationItem extends IRecord {
  id: number;
  name: string;
  period: number; // In seconds
}

const collection: ExpirationItem[] = [
  { id: 1, name: '7 days', period: 7 },
  { id: 2, name: '30 days', period: 30 },
  { id: 3, name: '60 days', period: 60 },
  { id: 4, name: '90 days', period: 90 },
  { id: 5, name: 'Custom...', period: 0 },
  { id: 6, name: 'No expiration', period: 0 }
]

const dayMs = 60 * 60 * 24 * 1000
const msExp = /\.\d{3}Z$/

interface Props {
  id: string;
  label: string | null;
}

const ExpirationDatePicker: FunctionComponent<Props> = ({ id, label }) => {
  const today: Date = new Date()
  const tomorrow: Date = new Date(today)
  tomorrow.setDate(today.getDate() + 1)
  const [selectedItem, setSelectedItem] = useState(collection[0])
  const [pickedDate, setPickedDate] = useState(tomorrow)
  const fieldName = `human_${id}`
  const fieldLabel = label ?? 'Expires in'

  const fieldDate = useMemo(() => {
    if (selectedItem.period === 0) return null

    return new Date(today.getTime() + selectedItem.period * dayMs)
  }, [selectedItem])

  const dateValue = useMemo(() => {
    let value = ''

    if (fieldDate) {
      value = fieldDate.toISOString().replace(msExp, 'Z')
    } else if (selectedItem.id === 5 ) {
      value = pickedDate.toISOString().replace(msExp, 'Z')
    }

    return value
  }, [fieldDate, selectedItem, pickedDate])

  const fieldHint = useMemo(() => {
    if (!dateValue) return

    const date = new Date(dateValue)

    return `The token will expire on ${date.toString()}`
  }, [dateValue])

  const handleOnChange = (_value: string, event: FormEvent<HTMLSelectElement>) => {
    const value = (event.target as HTMLSelectElement).value
    const selected = collection.find(i => i.id.toString() === value) ?? null

    if (selected === null) return

    setSelectedItem(selected)
    setPickedDate(tomorrow)
  }

  const dateValidator = (date: Date): boolean => {
    return date >= today
  }

  return (
    <>
      <FormGroup
        isRequired
        fieldId={fieldName}
        label={fieldLabel}
        helperText={fieldHint}
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
                label={item.name}
                value={item.id}
              />
            )
          })}
        </FormSelect>
      </FormGroup>
      <input id={id} name={id} type="hidden" value={dateValue} />
      {selectedItem.id === 5 &&
        <CalendarMonth date={pickedDate} onChange={setPickedDate} validators={[dateValidator]}/>
      }
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
