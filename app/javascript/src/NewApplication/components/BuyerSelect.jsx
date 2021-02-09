// @flow

import React, { useState } from 'react'

import {
  FormGroup,
  Select,
  SelectVariant
} from '@patternfly/react-core'
import { toSelectOption, SelectOptionObject } from 'utilities/patternfly-utils'

import type { Buyer } from 'NewApplication/types'

const HEADER = { id: 'header', name: 'Most recently created Accounts', disabled: true, className: 'pf-c-select__menu-item--group-name' }
const SHOW_ALL_BUYERS = { id: 'foo', name: 'View all Accounts' }

type Props = {
  buyer: Buyer | null,
  buyers: Buyer[],
  onSelect: (Buyer | null) => void,
  onShowAll: () => void,
  isDisabled?: boolean
}

const MAX_BUYERS = 20

const BuyerSelect = ({ isDisabled = false, onSelect, onShowAll, buyers, buyer }: Props) => {
  const [expanded, setExpanded] = useState(false)

  const handleOnSelect = (_e, option: SelectOptionObject) => {
    setExpanded(false)

    if (option.id === SHOW_ALL_BUYERS.id) {
      onShowAll()
    } else {
      const selectedBuyer = buyers.find(b => b.id === option.id)

      if (selectedBuyer) {
        onSelect(selectedBuyer)
      }
    }
  }

  return (
    <FormGroup
      isRequired
      label="Account"
      fieldId="account_id"
    >
      {buyer && <input type="hidden" name="account_id" value={buyer.id} />}
      <Select
        id="account_id"
        name="account_id"
        variant={SelectVariant.typeahead}
        placeholderText="Select an account"
        selections={buyer && new SelectOptionObject(buyer)}
        onToggle={() => setExpanded(!expanded)}
        onSelect={handleOnSelect}
        isExpanded={expanded}
        onClear={() => onSelect(null)}
        aria-labelledby="account"
        className="pf-c-select__menu--with-fixed-link"
      >
        {[HEADER, ...buyers.slice(0, MAX_BUYERS), SHOW_ALL_BUYERS].map(b => toSelectOption({
          ...b,
          description: b.admin || undefined
        }))}
      </Select>
    </FormGroup>
  )
}

export { BuyerSelect }
