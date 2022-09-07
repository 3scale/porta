import * as React from 'react';

import escapeRegExp from 'lodash.escaperegexp'
import { SelectOption } from '@patternfly/react-core'

export type Record = {
  id: number | string,
  name: string,
  description?: string
};

// TODO: this should come from @patternfly/react-core typings, but they're not compatible with Flow
export interface SelectOptionObject {
  id: string;
  name: string;
  toString: () => string;
}

export const toSelectOptionObject = (item: Record): SelectOptionObject => ({
  id: String(item.id),
  name: item.name,
  toString: () => item.name
})

type Props = Record & {
  disabled?: boolean,
  className?: string
};

export const toSelectOption = (
  {
    id,
    name,
    description,
    disabled = false,
    className,
  }: Props,
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
export const handleOnFilter = (
  items: Array<Record>,
  getSelectOptionsForItems?: (arg1: Array<Record>) => Array<React.ReactElement>,
): any => {
  return (e: React.SyntheticEvent<HTMLInputElement>) => {
    const { value } = e.currentTarget
    const term = new RegExp(escapeRegExp(value), 'i')

    const filteredItems = value !== '' ? items.filter(b => term.test(b.name)) : items

    return getSelectOptionsForItems ? getSelectOptionsForItems(filteredItems)
      // $FlowIssue[prop-missing] description is optional
      : filteredItems.map(toSelectOption)
  };
}
