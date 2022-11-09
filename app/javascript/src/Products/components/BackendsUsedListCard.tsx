import { useRef, useState } from 'react'

import { CompactListCard } from 'Common/components/CompactListCard'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { useSearchInputEffect } from 'utilities/useSearchInputEffect'

import type { CompactListItem } from 'Common/components/CompactListCard'

interface Props {
  backends: CompactListItem[];
}

const BackendsUsedListCard: React.FunctionComponent<Props> = ({ backends }) => {
  const [page, setPage] = useState(1)
  const [filteredBackends, setFilteredBackends] = useState(backends)
  const searchInputRef = useRef<HTMLInputElement | null>(null)

  const handleOnSearch = (term = '') => {
    setFilteredBackends(backends.filter(b => {
      const regex = new RegExp(term, 'i')
      return regex.test(b.name)
    }))
    setPage(1)
  }

  useSearchInputEffect(searchInputRef, handleOnSearch)

  return (
    <CompactListCard
      columns={['Name', 'Private Endpoint']}
      items={filteredBackends}
      page={page}
      searchInputPlaceholder="Find a backend"
      searchInputRef={searchInputRef}
      setPage={setPage}
      tableAriaLabel="Backends used in this product"
      onSearch={handleOnSearch}
    />
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const BackendsUsedListCardWrapper = (props: Props, containerId: string): void => { createReactWrapper(<BackendsUsedListCard {...props} />, containerId) }

export { BackendsUsedListCard, BackendsUsedListCardWrapper, Props }
