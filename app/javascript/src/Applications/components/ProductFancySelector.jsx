// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  FormSelectOption,
  Select
} from '@patternfly/react-core'
import { toSelectOption } from 'utilities/patternfly-utils'

import type { Product } from 'Applications/types'

const DEFAULT_PRODUCT: Product = { disabled: true, id: -1, name: 'Select a Product', appPlans: [], servicePlans: [], defaultServicePlan: null }

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
        selections={selectedProduct}
        onToggle={() => setExpanded(!expanded)}
        onSelect={onSelectProduct}
        isExpanded={expanded}
      >
        {[DEFAULT_PRODUCT, ...products].map(toSelectOption)}
      </Select>
    </FormGroup>
  )
}

export { ProductFormSelector }
