import { useState, useMemo } from 'react'
import { Alert, CalendarMonth, FormGroup, FormSelect, FormSelectOption, Popover } from '@patternfly/react-core'
import OutlinedQuestionCircleIcon from '@patternfly/react-icons/dist/js/icons/outlined-question-circle-icon'


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
  tzOffset?: number;
}

const ExpirationDatePicker: FunctionComponent<Props> = ({ id, label, tzOffset }) => {
  const [selectedItem, setSelectedItem] = useState(collection[0])
  const [pickedDate, setPickedDate] = useState(new Date())
  const fieldName = `human_${id}`
  const fieldLabel = label ?? 'Expires in'

  const fieldDate = useMemo(() => {
    if (selectedItem.period === 0) return null

    return new Date(new Date().getTime() + selectedItem.period * dayMs)
  }, [selectedItem])

  const dateValue = useMemo(() => {
    let value = ''

    if (fieldDate) {
      value = fieldDate.toISOString()
    } else if (selectedItem.id === 'custom' ) {
      value = pickedDate.toISOString()
    }

    return value
  }, [fieldDate, selectedItem, pickedDate])

  const formattedDateValue = useMemo(() => {
    if (!dateValue) return

    const formatter = Intl.DateTimeFormat('en-US', {
      month: 'long', day: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric', hour12: false
    })
    const date = new Date(dateValue)

    return formatter.format(date)
  }, [dateValue])

  const fieldHint = useMemo(() => {
    if (!formattedDateValue) return

    return `The token will expire on ${formattedDateValue}`
  }, [formattedDateValue])

  const tzMismatch = useMemo(() => {
    if (tzOffset === undefined) return

    // Timezone offset in the same format as ActiveSupport
    const jsTzOffset = new Date().getTimezoneOffset() * -60

    return jsTzOffset !== tzOffset
  }, [tzOffset])

  const labelIcon = useMemo(() => {
    if (!tzMismatch) return

    return (
      <Popover
        bodyContent={(
          <p>
            Your local time zone differs from the provider default.
            The token will expire at the time you selected in your local time zone.
          </p>
        )}
        headerContent={(
          <span>Time zone mismatch</span>
        )}
      >
        <button
          aria-describedby="form-group-label-info"
          aria-label="Time zone mismatch warning"
          className="pf-c-form__group-label-help"
          type="button"
        >
          <OutlinedQuestionCircleIcon noVerticalAlign />
        </button>
      </Popover>
    )
  }, [tzMismatch])

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
        helperText={fieldHint}
        label={fieldLabel}
        labelIcon={labelIcon}
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

const ExpirationDatePickerWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ExpirationDatePicker id={props.id} label={props.label} tzOffset={props.tzOffset} />, containerId) }

export type { ExpirationItem, Props }
export { ExpirationDatePicker, ExpirationDatePickerWrapper }
