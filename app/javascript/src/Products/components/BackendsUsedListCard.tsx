import * as React from 'react'
import { useState, useRef } from 'react'

import { CompactListCard } from 'Common'
import { createReactWrapper, useSearchInputEffect } from 'utilities'

import type { CompactListItem } from 'Common/components/CompactListCard'

type Props = {
  backends: Array<CompactListItem>
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
      searchInputRef={searchInputRef}
      onSearch={handleOnSearch}
      page={page}
      setPage={setPage}
      searchInputPlaceholder="Find a backend"
      tableAriaLabel="Backends used in this product"
    />
  )
}

const BackendsUsedListCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<BackendsUsedListCard {...props} />, containerId)

export { BackendsUsedListCard, BackendsUsedListCardWrapper, Props }
