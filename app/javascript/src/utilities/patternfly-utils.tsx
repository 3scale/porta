
import escapeRegExp from 'lodash.escaperegexp'
import { SelectOption, SelectOptionObject as PFSelectOptionObject } from '@patternfly/react-core'

export type Record = {
  id: number | string,
  name: string,
  description?: string
};

export interface SelectOptionObject extends PFSelectOptionObject {
  id: string
  name: string
}

// TODO: check removing id and name is correct
export const toSelectOptionObject = (item: Record): SelectOptionObject => ({
  id: String(item.id),
  name: item.name,
  toString: () => item.name
})

type Props = Record & {
  disabled?: boolean,
  className?: string
}

export const toSelectOption = ({
  id,
  name,
  description,
  disabled = false,
  className
}: Props): React.ReactElement => (
  <SelectOption
    key={String(id)}
    value={toSelectOptionObject({ id, name, description })}
    className={className}
    // TODO: when we upgrade PF, use description prop directly
    // description={record.description}
    data-description={description}
    isDisabled={disabled}
/>
)

/**
 * It creates a callback that's to be passed to a PF4 select of variant "typeahead"
 */
export const handleOnFilter = <T extends Record>(
  items: T[],
  getSelectOptionsForItems?: (items: T[]) => React.ReactElement[]
) => {
  return (e: React.SyntheticEvent<HTMLInputElement>) => {
    const { value } = e.currentTarget
    const term = new RegExp(escapeRegExp(value), 'i')

    const filteredItems = value !== '' ? items.filter(b => term.test(b.name)) : items

    return getSelectOptionsForItems
      ? getSelectOptionsForItems(filteredItems)
      : filteredItems.map(toSelectOption)
  }
}
