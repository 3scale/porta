// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  FormSelectOption,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import { toSelectOption } from 'utilities/patternfly-utils'

import type { Product } from 'NewApplication/types'

const HEADER = { id: 'header', name: 'Most recently created products', disabled: true, className: 'pf-c-select__menu-item--group-name' }
const SHOW_ALL_PRODUCTS = { id: 'foo', name: 'View all Products' }

const options = [
  { name: 'Product-01', id: '01', systemName: 'product_01' },
  { name: 'Product-02', id: '02', systemName: 'product_02' },
  { name: 'Product-03', id: '03', systemName: 'product_03' },
  { name: 'Product-04', id: '04', systemName: 'product_04' },
  { name: 'Product-05', id: '05', systemName: 'product_05' },
  { name: 'Product-06', id: '06', systemName: 'product_06' },
  { name: 'Product-07', id: '07', systemName: 'product_07' },
  { name: 'Product-08', id: '08', systemName: 'product_08' },
  { name: 'Product-09', id: '09', systemName: 'product_09' },
  { name: 'Product-10', id: '10', systemName: 'product_10' },
  { name: 'Product-11', id: '11', systemName: 'product_11' },
  { name: 'Product-12', id: '12', systemName: 'product_12' },
  { name: 'Product-13', id: '13', systemName: 'product_13' },
  { name: 'Product-14', id: '14', systemName: 'product_14' },
  { name: 'Product-15', id: '15', systemName: 'product_15' },
  { name: 'Product-16', id: '16', systemName: 'product_16' },
  { name: 'Product-17', id: '17', systemName: 'product_17' },
  { name: 'Product-18', id: '18', systemName: 'product_18' },
  { name: 'Product-19', id: '19', systemName: 'product_19' }
]

type Props = {
  products: Product[],
  onSelect: Product => void,
  isDisabled?: boolean
}

const ProductFormSelector = ({ isDisabled = false, onSelect, products }: Props) => {
  const [expanded, setExpanded] = useState(false)

  const selectedProduct: FormSelectOption = null

  const onSelectProduct = (_e, product) => {
    setExpanded(false)

    if (product.id === SHOW_ALL_PRODUCTS.id) {
      console.log('open modal')
    } else {
      onSelect(product)
    }
  }

  return (
    <FormGroup
      isRequired
      label="Fancy Product"
      fieldId="product"
    >
      <Select
        // Not to be submitted, do not add "name"
        variant={SelectVariant.typeahead}
        placeholderText="Select a product"
        selections={selectedProduct}
        onToggle={() => setExpanded(!expanded)}
        onSelect={onSelectProduct}
        onClear={() => {}}
        isExpanded={expanded}
        isGrouped={true}
        aria-labelledby="product"
        className="pf-c-select__menu--with-fixed-link"
      >
        {[HEADER, ...options, SHOW_ALL_PRODUCTS].map(toSelectOption)}
      </Select>
    </FormGroup>
  )
}
export { ProductFormSelector }
