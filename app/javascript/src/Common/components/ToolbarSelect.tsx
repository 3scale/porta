import { useState } from 'react'
import {
  Select,
  SelectOption
} from '@patternfly/react-core'

import type { SelectProps } from '@patternfly/react-core'

interface Props {
  attribute: string;
  collection: {
    id: string;
    title: string;
  }[];
  placeholder: string;
}

const INPUT_NAME_UTF8 = 'utf8'

const ToolbarSelect: React.FunctionComponent<Props> = ({
  attribute,
  collection,
  placeholder
}) => {
  const name = `search[${attribute}]`
  const url = new URL(window.location.href)
  const selectedId = url.searchParams.get(name)

  const [isOpen, setIsOpen] = useState(false)
  const [selected, setSelected] = useState(collection.find(item => item.id === selectedId)?.title ?? null)

  const handleOnSelect: SelectProps['onSelect'] = (_e, value) => {
    url.searchParams.set(INPUT_NAME_UTF8, '✓')

    if (value === selected) {
      setSelected(null)
      url.searchParams.delete(name)

    } else {
      setSelected(value as string)
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      url.searchParams.set(name, collection.find(i => i.title === value)!.id)
    }

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
      onSelect={handleOnSelect}
      onToggle={setIsOpen}
    >
      {options}
    </Select>
  )
}

export type { Props }
export { ToolbarSelect }
