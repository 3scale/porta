import escapeRegExp from 'lodash.escaperegexp'
import { SelectOption } from '@patternfly/react-core'

import type { SelectOptionObject as PFSelectOptionObject, SelectOptionProps } from '@patternfly/react-core'
import type { ISortBy, ThProps } from '@patternfly/react-table'

// TODO: IRecord is duplicated
export interface IRecord {
  id: number | string;
  name: string;
  description?: string;
}

export interface SelectOptionObject extends PFSelectOptionObject {
  id: string;
  name: string;
}

// TODO: check removing id and name is correct
export const toSelectOptionObject = (item: IRecord): SelectOptionObject => ({
  id: String(item.id),
  name: item.name,
  compareTo: (other: SelectOptionObject) => other.id === String(item.id),
  toString: () => item.name
})

export interface ISelectOption extends IRecord {
  disabled?: boolean;
  className?: string;
}

export const toSelectOption = ({
  id,
  name,
  description,
  disabled = false,
  className
}: ISelectOption): React.ReactElement<SelectOptionProps> => (
  <SelectOption
    key={String(id)}
    className={className}
    description={description}
    isDisabled={disabled}
    value={toSelectOptionObject({ id, name })}
  />
)

/**
 * It creates a callback that's to be passed to a PF4 select of variant "typeahead"
 */
export const handleOnFilter = <T extends IRecord>(
  items: T[],
  getSelectOptionsForItems?: (items: T[]) => React.ReactElement<SelectOptionProps>[]
) => {
  return (_e: unknown, value: string): React.ReactElement[] | undefined => {
    const term = new RegExp(escapeRegExp(value), 'i')

    const filteredItems = value !== '' ? items.filter(b => term.test(b.name)) : items

    return getSelectOptionsForItems
      ? getSelectOptionsForItems(filteredItems)
      : filteredItems.map(toSelectOption)
  }
}

/**
 * To make a column sortable, pass a ThSortType object via the sort prop on a column's Th.
 * Inspired by http://v4-archive.patternfly.org/v4/components/table/#composable-sortable--wrapping-headers
 *
 * This is for Table Composable, not legacy.
 *
 * @param columnIndex - Index of the current column
 * @param sort - Attribute name (from model) corresponding to this column
 * @example
 *   const columns = [
 *     { label: 'Name', sort: getSortParams(0, 'name') },
 *     { label: 'Created on', sort: getSortParams(1, 'created_at') },
 *     { label: 'Applications' },
 *   ]
 */
export const getSortParams = (columnIndex: number, sort: string): ThProps['sort'] => {
  const url = new URL(window.location.href)
  const sortParam = url.searchParams.get('sort')

  return {
    sortBy: {
      index: sortParam === sort ? columnIndex : undefined,
      direction: url.searchParams.get('direction') as ISortBy['direction'],
      defaultDirection: 'desc'
    },
    onSort: (_event, _index, direction) => {
      url.searchParams.set('direction', direction)
      url.searchParams.set('sort', sort )
      window.location.replace(url.toString())
    },
    columnIndex
  }
}
