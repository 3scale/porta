import moment from 'moment'
import { useState } from 'react'
import {
  Alert,
  CalendarMonth,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Popover
} from '@patternfly/react-core'
import ExclamationTriangleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-triangle-icon'

import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'

import './ExpirationDatePicker.scss'

const TIMESTAMP_FORMAT = 'YYYY-MM-DDTHH:mm:ssZ'

interface ExpirationItem {
  id: string;
  label: string;
  period: number; // In days
}

const collection: ExpirationItem[] = [
  { id: '7', label: '7 days', period: 7 },
  { id: '30', label: '30 days', period: 30 },
  { id: '60', label: '60 days', period: 60 },
  { id: '90', label: '90 days', period: 90 },
  { id: 'custom', label: 'Custom...', period: 0 },
  { id: 'no-exp', label: 'No expiration', period: 0 }
]

const today: Date = new Date()
const tomorrow: Date = new Date(today)
tomorrow.setDate(today.getDate() + 1)
const dayMs = 60 * 60 * 24 * 1000

const computeDropdownDate = (dropdownSelectedItem: ExpirationItem) => {
  if (dropdownSelectedItem.period === 0) return null

  return new Date(today.getTime() + dropdownSelectedItem.period * dayMs)
}

const computeSelectedDate = (dropdownDate: Date | null, dropdownSelectedItem: ExpirationItem, calendarPickedDate: Date) => {
  if (dropdownDate) return dropdownDate

  return dropdownSelectedItem.id === 'custom' ? calendarPickedDate : null
}

const computeFormattedDateValue = (selectedDate: Date | null) => {
  if (!selectedDate) return ''

  const formatter = Intl.DateTimeFormat('en-US', {
    month: 'long', day: 'numeric', year: 'numeric', hour: 'numeric', minute: 'numeric', hour12: false, timeZoneName: 'short'
  })

  return formatter.format(selectedDate)
}

const computeFieldHint = (formattedDateValue: string) => {
  if (!formattedDateValue) return

  return `The token will expire on ${formattedDateValue}`
}

const computeTzMismatch = (tzOffset: number) => {
  // Timezone offset in the same format as ActiveSupport
  const jsTzOffset = new Date().getTimezoneOffset() * -60

  return jsTzOffset !== tzOffset
}

const computeTzMismatchIcon = (tzMismatch: boolean) => {
  if (!tzMismatch) return

  return (
    <Popover
      bodyContent={(
        <p>
            Your local time zone differs from the account settings.
            The selected date might be reported in the account time zone.
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
        <ExclamationTriangleIcon noVerticalAlign />
      </button>
    </Popover>
  )
}

const computeInputDateValue = (selectedDate: Date | null) => {
  if (!selectedDate) return ''

  return moment(selectedDate).utc().format(TIMESTAMP_FORMAT)
}

interface Props {
  id: string;
  label: string | null;
  tzOffset: number;
}

const ExpirationDatePicker: FunctionComponent<Props> = ({ id, label, tzOffset }) => {
  const [dropdownSelectedItem, setDropdownSelectedItem] = useState(collection[0])
  const [calendarPickedDate, setCalendarPickedDate] = useState(tomorrow)

  const dropdownDate = computeDropdownDate(dropdownSelectedItem)
  const selectedDate = computeSelectedDate(dropdownDate, dropdownSelectedItem, calendarPickedDate)
  const formattedDateValue = computeFormattedDateValue(selectedDate)
  const fieldHint = computeFieldHint(formattedDateValue)
  const tzMismatch = computeTzMismatch(tzOffset)
  const tzMismatchIcon = computeTzMismatchIcon(tzMismatch)
  const inputDateValue = computeInputDateValue(selectedDate)
  const fieldName = `human_${id}`
  const fieldLabel = label ?? 'Expires in'

  const handleOnChange = (value: string) => {
    const selected = collection.find(i => i.id === value) ?? null

    if (selected === null) return

    setDropdownSelectedItem(selected)
    setCalendarPickedDate(tomorrow)
  }

  const dateValidator = (date: Date): boolean => {
    return date >= today
  }

  return (
    <>
      <FormGroup
        isRequired
        fieldId={fieldName}
        helperText={fieldHint}
        label={fieldLabel}
        labelIcon={tzMismatchIcon}
      >
        <FormSelect
          className="pf-c-form-control-expiration"
          id={fieldName}
          value={dropdownSelectedItem.id}
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
      <input id={id} name={id} type="hidden" value={inputDateValue} />
      {dropdownSelectedItem.id === 'custom' && (
        <CalendarMonth className="pf-u-mt-md" date={calendarPickedDate} validators={[dateValidator]} onChange={setCalendarPickedDate} />
      )}
      {!selectedDate && (
        <Alert className="pf-u-mt-md" title="Expiration is recommended" variant="warning">
          It is strongly recommended that you set an expiration date for your token to help keep your information
          secure
        </Alert>
      )}
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ExpirationDatePickerWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ExpirationDatePicker {...props} />, containerId) }

export type { ExpirationItem, Props }
export { ExpirationDatePicker, ExpirationDatePickerWrapper, TIMESTAMP_FORMAT }
