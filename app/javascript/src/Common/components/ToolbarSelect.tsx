import { useState } from 'react'
import {
  Select,
  SelectOption
} from '@patternfly/react-core'

import type { SelectProps } from '@patternfly/react-core'

interface Props {
  collection: {
    id: string;
    title: string;
  }[];
  name: string;
  placeholder: string;
}

const INPUT_NAME_UTF8 = 'utf8'

const ToolbarSelect: React.FunctionComponent<Props> = ({
  collection,
  placeholder,
  name
}) => {
  const url = new URL(window.location.href)
  const selectedId = url.searchParams.get(name)

  const [isOpen, setIsOpen] = useState(false)
  const selected = collection.find(item => item.id === selectedId)?.title ?? null

  const clearSelection = () => {
    url.searchParams.delete('page')
    url.searchParams.delete(name)
    window.location.replace(url.toString())
  }

  const handleOnSelect: SelectProps['onSelect'] = (_e, value) => {
    if (value === selected) {
      setIsOpen(false)
      return
    }

    url.searchParams.delete('page')
    url.searchParams.set(INPUT_NAME_UTF8, '✓')
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    url.searchParams.set(name, collection.find(i => i.title === value)!.id)
    window.location.replace(url.toString())
  }

  const options = collection.map(({ id, title }) => <SelectOption key={id} value={title} />)

  return (
    <Select
      isOpen={isOpen}
      ouiaId={placeholder}
      placeholderText={placeholder}
      // @ts-expect-error -- Type is wrong...
      selections={selected}
      onClear={clearSelection}
      onSelect={handleOnSelect}
      onToggle={setIsOpen}
    >
      {options}
    </Select>
  )
}

export type { Props }
export { ToolbarSelect }
