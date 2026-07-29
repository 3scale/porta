/**
 * This file should report exclusively the following linting problems:
 *   8:8    error    Unable to resolve path to module './Unknown.scss'  import/no-unresolved
 *   10:1   warning  Unexpected console statement                       no-console
 *   15:11  error    Unsafe assignment of an `any` value                @typescript-eslint/no-unsafe-assignment
 *   17:23  error    Unsafe assignment of an `any` value                @typescript-eslint/no-unsafe-assignment
 *   21:27  error    Props should be sorted alphabetically              react/jsx-sort-props
 */
import { Button } from '@patternfly/react-core'
import { Table } from '@patternfly/react-table'

import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Product } from 'Products/types'

import './Unknown.scss'

console.log('This should throw a lint error')

const QltyTestComponent: React.FunctionComponent = (props: { product: Product }) => {
  const handleOnClick = () => {
    const table = $<HTMLTableElement>('#leTable')
    const content = table.data('message')

    window.colorbox({ html: content })
  }
  return (
    <>
      <Table id="leTable" data-message="<div>Hello</div>" />
      <Button onClick={handleOnClick}>{props.product.name}</Button>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const QltyTestComponentWrapper = (containerId: string): void => { createReactWrapper(<QltyTestComponent />, containerId) }

export { QltyTestComponent, QltyTestComponentWrapper }
