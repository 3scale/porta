// @flow

import React from 'react'

import { FormGroup, FormSelect } from '@patternfly/react-core'
import { toFormSelectOption } from 'utilities/patternfly-utils'
import type { Buyer } from 'NewApplication/types'

type Props = {
  // props here
}

const BUYER_PLACEHOLDER: Buyer = { disabled: true, id: '-1', name: 'Select an Account', contractedProducts: [], servicePlans: [], createApplicationPath: '' }

const BuyerSelect = (props: Props) => {
  // logic here

  return (
    <FormGroup
      label="Account"
      isRequired
      fieldId="account_id"
    >
      <FormSelect
        value={undefined}
        onChange={(id) => console.log('setBuyer(buyers.find(a => a.id === id))')}
        id="account_id"
        name="account_id"
      >
        {/* {buyers.map((b) => (
                <FormSelectOption isDisabled={b.disabled} key={b.id} value={b.id} label={b.name} />
              ))} */}
        {/* $FlowFixMe */}
        {[BUYER_PLACEHOLDER].map(toFormSelectOption)}
      </FormSelect>
    </FormGroup>
  )
}

export { BuyerSelect, BUYER_PLACEHOLDER }
