// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import { toSelectOption, SelectOptionObject } from 'utilities/patternfly-utils'

import type { Buyer } from 'NewApplication/types'

type Props = {
  buyer: Buyer | null,
  buyers: Buyer[],
  onSelect: (Buyer | null) => void
}

const BuyerSelect = ({ buyer, buyers, onSelect }: Props) => {
  const [expanded, setExpanded] = useState<boolean>(false)

  const handleOnSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)
    const selectedBuyer = buyers.find(b => b.id.toString() === option.id)

    onSelect(selectedBuyer || null)
  }

  return (
    <FormGroup
      isRequired
      label="Account"
      fieldId="account_id"
    >
      <Select
        id="account_id"
        name="account_id"
        variant={SelectVariant.typeahead}
        placeholderText="Select an account"
        // $FlowFixMe Flow wrong here
        selections={buyer && new SelectOptionObject(buyer)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleOnSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby="account"
      >
        {/* $FlowFixMe Flow wrong here */}
        {buyers.map(toSelectOption)}
      </Select>
    </FormGroup>
  )
}

export { BuyerSelect }
