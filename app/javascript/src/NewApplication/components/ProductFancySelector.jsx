// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  FormSelectOption,
  Select,
  SelectGroup,
  SelectOption,
  SelectVariant
} from '@patternfly/react-core'
// import { toSelectOption } from 'utilities/patternfly-utils'

import type { Product } from 'NewApplication/types'

// const DEFAULT_PRODUCT: Product = { disabled: true, id: -1, name: 'Select a Product', label: 'Vendor Names', key: 'group2', appPlans: [], servicePlans: [], defaultServicePlan: null }

const options = [
  <SelectGroup label="Most recently created Products" key="group1">
    <SelectOption key={0} value="Product-01" description="please"/>
    <SelectOption key={1} value="Product-02" />
    <SelectOption key={2} value="Product-03" />
    <SelectOption key={3} value="Product-04" />
    <SelectOption key={4} value="Product-05" />
  </SelectGroup>,
  <SelectGroup label="All products" key="group2">
    <SelectOption key={5} value="Product-06" />
    <SelectOption key={6} value="Product-07" isDisabled />
    <SelectOption key={7} value="Product-08" />
  </SelectGroup>
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
    onSelect(product)
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
        selections={selectedProduct}
        onToggle={() => setExpanded(!expanded)}
        onSelect={onSelectProduct}
        isExpanded={expanded}
        isGrouped={true}
      >
        {/* {[DEFAULT_PRODUCT, ...products].map(toSelectOption)} */}
        {options}
      </Select>
    </FormGroup>
  )
}

export { ProductFormSelector }
