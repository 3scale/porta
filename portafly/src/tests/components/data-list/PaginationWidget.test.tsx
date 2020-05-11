import React from 'react'

import { render } from 'tests/custom-render'
import { PaginationWidget, DataListProvider } from 'components/data-list'

const setup = ({ itemCount }: any) => render(
  <DataListProvider>
    <PaginationWidget itemCount={itemCount} />
  </DataListProvider>
)

it('should render compacted when there are 1-2 pages only', () => {
  const wrapper = setup({ itemCount: 1 })
  expect(wrapper.container.querySelector('.pf-m-compact')).toBeInTheDocument()
})

it('should render NOT compacted when there are 3 or more pages', () => {
  const wrapper = setup({ itemCount: 150 })
  expect(wrapper.container.querySelector('.pf-m-compact')).not.toBeInTheDocument()
})

it.skip('should change list section when paginating')
