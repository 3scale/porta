import * as React from 'react'

import escapeRegExp from 'lodash.escaperegexp'
import { SelectOption, SelectOptionObject } from '@patternfly/react-core'

export type Record = {
  id: number | string,
  name: string,
  description?: string
};

// TODO: this should come from @patternfly/react-core typings, but they're not compatible with Flow
// export interface SelectOptionObject {
//   id: string;
//   name: string;
//   toString: () => string;
// }

// TODO: check removing id and name is correct
export const toSelectOptionObject = (item: Record): SelectOptionObject => ({
  toString: () => item.name
})

type Props = Record & {
  disabled?: boolean,
  className?: string
}

export const toSelectOption = (
  {
    id,
    name,
    description,
    disabled = false,
    className
  }: Props
): React.ReactElement => <SelectOption
  key={String(id)}
  value={toSelectOptionObject({ id, name, description })}
  className={className}
  // TODO: when we upgrade PF, use description prop directly
  // description={record.description}
  data-description={description}
  isDisabled={disabled}
/>

/**
 * It creates a callback that's to be passed to a PF4 select of variant "typeahead"
 */
export const handleOnFilter = <T extends Record>(
  items: T[],
  getSelectOptionsForItems?: (arg1: T[]) => React.ReactElement[]
): (e: React.ChangeEvent<HTMLInputElement>) => React.ReactElement[] => {
  return (e: React.SyntheticEvent<HTMLInputElement>) => {
    const { value } = e.currentTarget
    const term = new RegExp(escapeRegExp(value), 'i')

    const filteredItems = value !== '' ? items.filter(b => term.test(b.name)) : items

    return getSelectOptionsForItems
      ? getSelectOptionsForItems(filteredItems)
      : filteredItems.map(toSelectOption)
  }
}
