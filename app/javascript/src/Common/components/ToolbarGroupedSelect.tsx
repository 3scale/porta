import { useState } from 'react'
import {
  Select,
  SelectGroup,
  SelectOption
} from '@patternfly/react-core'

import { toSelectOptionObject } from 'utilities/patternfly-utils'

import type { IRecord, SelectOptionObject } from 'utilities/patternfly-utils'
import type { SelectProps } from '@patternfly/react-core'

interface Item {
  id: string;
  title: string;
}

interface Props {
  collection: {
    groupName: string;
    groupCollection: Item[];
  }[];
  name: string;
  placeholder: string;
  selected?: IRecord;
}

const INPUT_NAME_UTF8 = 'utf8'

const ToolbarGroupedSelect: React.FunctionComponent<Props> = ({
  selected,
  collection,
  placeholder,
  name
}) => {
  const [isOpen, setIsOpen] = useState(false)

  const clearSelection = () => {
    const search = new URLSearchParams(window.location.search)
    search.delete(name)
    window.location.search = search.toString()
  }

  const handleOnSelect: SelectProps['onSelect'] = (_e, rawValue: unknown) => {
    const value = rawValue as SelectOptionObject

    if (value.id === selected?.id) {
      setIsOpen(false)
      return
    }

    collection.some(group => {
      const found = group.groupCollection.find(item => item.id === value.id)

      if (found) {
        const search = new URLSearchParams(window.location.search)
        search.delete('page')
        search.set(INPUT_NAME_UTF8, '✓')
        search.set(name, found.id)
        window.location.search = search.toString()
        return true
      } else {
        return false
      }
    })
  }

  return (
    <Select
      isGrouped
      isOpen={isOpen}
      ouiaId={placeholder}
      placeholderText={placeholder}
      selections={selected && toSelectOptionObject(selected)}
      onClear={clearSelection}
      onSelect={handleOnSelect}
      onToggle={setIsOpen}
    >
      {collection.map(group => (
        <SelectGroup key={group.groupName} label={group.groupName}>
          {group.groupCollection.map(({ id, title }) => (
            <SelectOption
              key={id}
              value={toSelectOptionObject({ id, name: title })}
            />
          ))}
        </SelectGroup>
      ))}
    </Select>
  )
}

export type { Props }
export { ToolbarGroupedSelect }
