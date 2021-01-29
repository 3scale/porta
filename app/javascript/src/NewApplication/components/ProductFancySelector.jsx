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

// Tried to remove Select a Product but I keep getting a blank option
// const DEFAULT_PRODUCT: Product = { disabled: true, id: -1, name: 'Select a Product', label: 'Vendor Names', key: 'group2', appPlans: [], servicePlans: [], defaultServicePlan: null }

const options = [
  <SelectGroup label="Most recently created Products" key="group1">
    <SelectOption key={0} value="Product-01" description="please"/>
    <SelectOption key={1} value="Product-02" />
    <SelectOption key={2} value="Product-03" />
    <SelectOption key={3} value="Product-04" />
    <SelectOption key={4} value="Product-05" />
    <SelectOption key={5} value="Product-06" />
    <SelectOption key={6} value="Product-07" isDisabled />
    <SelectOption key={7} value="Product-08" />
    <SelectOption key={8} value="Product-09" />
    <SelectOption key={9} value="Product-10" />
    <SelectOption key={10} value="Product-11" />
    <SelectOption key={11} value="Product-12" />
    <SelectOption key={12} value="Product-13" />
    <SelectOption key={13} value="Product-14" />
    <SelectOption key={14} value="Product-15" />
    <SelectOption key={15} value="Product-16" />
    <SelectOption key={16} value="Product-17" />
    <SelectOption key={17} value="Product-18" />
    <SelectOption key={18} value="Product-19" />
    <SelectOption key={19} value="See all products" className="select-option--fixed-link" />
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
        placeholderText="Select a product"
        selections={selectedProduct}
        onToggle={() => setExpanded(!expanded)}
        onSelect={onSelectProduct}
        onClear={() => {}}
        isExpanded={expanded}
        isGrouped={true}
        aria-labelledby="product"
      >
        {/* <SelectGroup label="Most recently created Products" key="group1">
          {[DEFAULT_PRODUCT, ...products].map(toSelectOption)}
        </SelectGroup> */}

        {options}
      </Select>
    </FormGroup>
  )
}

export { ProductFormSelector }
