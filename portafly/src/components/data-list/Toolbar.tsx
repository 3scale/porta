import React from 'react'
import { DataToolbar } from '@patternfly/react-core/dist/js/experimental'
import { useDataListFilters } from 'components/data-list'

interface Props {
}

const Toolbar: React.FunctionComponent<Props> = ({ children }) => {
  const { setFilters } = useDataListFilters()
  return (
    <DataToolbar id="toolbar" clearAllFilters={() => setFilters({})}>
      {children}
    </DataToolbar>
  )
}

export { Toolbar }
