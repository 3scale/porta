// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import { toSelectOption } from 'utilities/patternfly-utils'

import type { Product } from 'NewApplication/types'

const HEADER = { id: 'header', name: 'Most recently created products', disabled: true, className: 'pf-c-select__menu-item--group-name' }
const SHOW_ALL_PRODUCTS = { id: 'foo', name: 'View all Products' }

type Props = {
  product: Product,
  products: Product[],
  onSelect: Product => void,
  onShowAll: () => void,
  isDisabled?: boolean
}

const ProductFormSelector = ({ isDisabled = false, onSelect, onShowAll, products, product }: Props) => {
  const [expanded, setExpanded] = useState(false)

  const onSelectProduct = (_e, product) => {
    setExpanded(false)

    if (product.id === SHOW_ALL_PRODUCTS.id) {
      onShowAll()
    } else {
      onSelect(product)
    }
  }

  return (
    <FormGroup
      isRequired
      label="Product"
      fieldId="product"
    >
      <Select
        // Not to be submitted, do not add "name"
        variant={SelectVariant.typeahead}
        placeholderText="Select a product"
        selections={product}
        onToggle={() => setExpanded(!expanded)}
        onSelect={onSelectProduct}
        isExpanded={expanded}
        isGrouped={true}
        aria-labelledby="product"
        className="pf-c-select__menu--with-fixed-link"
      >
        {/* $FlowFixMe */}
        {[HEADER, ...products, SHOW_ALL_PRODUCTS].map(toSelectOption)}
      </Select>
    </FormGroup>
  )
}
export { ProductFormSelector }
