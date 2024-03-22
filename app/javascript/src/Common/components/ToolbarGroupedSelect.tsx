import { useState } from 'react'
import {
  Select,
  SelectGroup,
  SelectOption
} from '@patternfly/react-core'

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
  selected?: string;
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

  const handleOnSelect: SelectProps['onSelect'] = (_e, value) => {
    if (value === selected) {
      setIsOpen(false)
      return
    }

    collection.some(group => {
      const found = group.groupCollection.find(item => item.title === value)

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
      selections={selected}
      onClear={clearSelection}
      onSelect={handleOnSelect}
      onToggle={setIsOpen}
    >
      {collection.map(group => (
        <SelectGroup key={group.groupName} label={group.groupName}>
          {group.groupCollection.map(({ id, title }) => (
            <SelectOption key={id} value={title} />
          ))}
        </SelectGroup>
      ))}
    </Select>
  )
}

export type { Props }
export { ToolbarGroupedSelect }
