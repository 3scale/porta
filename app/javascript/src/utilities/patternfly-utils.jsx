// @flow

import * as React from 'react'

import { SelectOption } from '@patternfly/react-core'

export type Record = {
  id: number | string,
  name: string,
  description?: string
}

// TODO: this should come from @patternfly/react-core typings, but they're not compatible with Flow
export interface SelectOptionObject {
  id: string,
  name: string,
  toString: () => string
}

export const toSelectOptionObject = (item: Record): SelectOptionObject => ({
  id: String(item.id),
  name: item.name,
  toString: () => item.description ? `${item.name} (${item.description})` : item.name
})

type Props = Record & {
  disabled?: boolean,
  className?: string
}

export const toSelectOption = ({ id, name, description, disabled = false, className }: Props): React.Node => (
  <SelectOption
    key={id}
    value={toSelectOptionObject({ id, name, description })}
    className={className}
    // TODO: when we upgrade PF, use description prop directly
    // description={record.description}
    data-description={description}
    isDisabled={disabled}
  />
)
