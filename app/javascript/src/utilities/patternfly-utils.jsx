// @flow

import React from 'react'

import { SelectOption } from '@patternfly/react-core'

export interface Record {
  id: number | string,
  name: string
}

export interface SelectOptionObject {
  id: string,
  name: string,
  toString: () => string
}

export const toSelectOptionObject = (item: Record): SelectOptionObject => ({
  id: String(item.id),
  name: item.name,
  toString: () => item.name
})

type Props = Record & {
  disabled?: boolean | void
}

export const toSelectOption = ({ id, name, description, disabled = false, className }: Props) => (
  <SelectOption
    key={id}
    value={toSelectOptionObject({ id, name })}
    isDisabled={disabled}
    className={className}
    description={description}
  />
)
