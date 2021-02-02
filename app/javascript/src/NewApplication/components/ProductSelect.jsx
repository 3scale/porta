// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import { toSelectOption, SelectOptionObject } from 'utilities/patternfly-utils'

import type { Product } from 'NewApplication/types'

const HEADER = { id: 'header', name: 'Most recently created products', disabled: true, className: 'pf-c-select__menu-item--group-name' }
const SHOW_ALL_PRODUCTS = { id: 'foo', name: 'View all Products' }

type Props = {
  product: Product | null,
  products: Product[],
  onSelect: (Product | null) => void,
  onShowAll: () => void,
  isDisabled?: boolean
}

const ProductSelect = ({ isDisabled = false, onSelect, onShowAll, products, product }: Props) => {
  const [expanded, setExpanded] = useState(false)

  const handleOnSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    if (option.id === SHOW_ALL_PRODUCTS.id) {
      onShowAll()
    } else {
      const selectedProduct = products.find(p => p.id.toString() === option.id)

      if (selectedProduct) {
        onSelect(selectedProduct)
      }
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
        selections={product && new SelectOptionObject(product)} // Flow is wrong here
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleOnSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby="product"
        className="pf-c-select__menu--with-fixed-link"
      >
        {/* $FlowFixMe */}
        {[HEADER, ...products, SHOW_ALL_PRODUCTS].map(toSelectOption)}
      </Select>
    </FormGroup>
  )
}
export { ProductSelect }
