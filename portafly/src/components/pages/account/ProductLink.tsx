import React from 'react'
import { IProduct } from 'types'
import { Button } from '@patternfly/react-core'

interface Props {
  product: IProduct
}

const ProductLink: React.FunctionComponent<Props> = ({ product }) => (
  <Button
    aria-label={product.name}
    component="a"
    variant="link"
    href={`/products/${product.id}`} // TODO: probably wrong path
    isInline
  >
    {product.name}
  </Button>
)

export { ProductLink }
