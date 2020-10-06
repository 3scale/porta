// @flow

import React from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'

type Props = {
  newProductPath: string,
  productsPath: string,
  products: Array<{
    name: string,
    path: string,
    updatedAt: string,
    links: Array<{
      name: string,
      path: string
    }>
  }>
}

const ProductsWidget = (props: Props) => {
  console.log(props)

  return (
    <div>Products</div>
  )
}

const ProductsWidgetWrapper = (props: Props, containerId: string) => createReactWrapper(<ProductsWidget {...props} />, containerId)

export { ProductsWidgetWrapper }
