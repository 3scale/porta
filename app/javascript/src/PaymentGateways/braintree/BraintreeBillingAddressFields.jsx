// @flow

import React, { useState } from 'react'
import { Label, Input, ListItem } from 'PaymentGateways'
import type { Node } from 'react'
import type { BillingAddressProps } from 'PaymentGateways'

const BraintreeBillingAddressFields = ({
  countriesList,
  billingAddressData,
  setBillingAddressData,
  selectedCountryCode = ''
}: BillingAddressProps): Node => {
  const [selectValue, setSelectValue] = useState(selectedCountryCode)

  const onChangeBillingAddressData = (value: string, field: string) => {
    setBillingAddressData({
      ...billingAddressData,
      [field]: value
    })
  }

  const onSelectCountry = (e) => {
    setSelectValue(e.currentTarget.value)
    onChangeBillingAddressData(e.currentTarget.options[e.currentTarget.selectedIndex].text, 'country')
  }

  return (
    <>
      <legend>Billing address</legend>
      <ul className="list-unstyled">
        <ListItem id="customer_credit_card_billing_address_company_input">
          <Label
            htmlFor="customer_credit_card_billing_address_company"
            label="Company"
            required
          />
          <Input
            id="customer_credit_card_billing_address_company"
            name="customer[credit_card][billing_address][company]"
            value={billingAddressData.company}
            onChange={(e) => onChangeBillingAddressData(e.currentTarget.value, 'company')}
            required
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_street_address_input">
          <Label
            htmlFor="customer_credit_card_billing_address_street_address"
            label="Street address"
            required
          />
          <Input
            id="customer_credit_card_billing_address_street_address"
            required
            name="customer[credit_card][billing_address][street_address]"
            value={billingAddressData.address1}
            onChange={(e) => onChangeBillingAddressData(e.currentTarget.value, 'address1')}
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_postal_code_input">
          <Label
            htmlFor="customer_credit_card_billing_address_postal_code"
            label="ZIP / Postal Code"
            required
          />
          <Input
            id="customer_credit_card_billing_address_postal_code"
            required
            name="customer[credit_card][billing_address][postal_code]"
            value={billingAddressData.zip}
            onChange={(e) => onChangeBillingAddressData(e.currentTarget.value, 'zip')}
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_locality_input">
          <Label
            htmlFor="customer_credit_card_billing_address_locality"
            label="City"
            required
          />
          <Input
            id="customer_credit_card_billing_address_locality"
            required
            name="customer[credit_card][billing_address][locality]"
            value={billingAddressData.city}
            onChange={(e) => onChangeBillingAddressData(e.currentTarget.value, 'city')}
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_region_input">
          <Label
            htmlFor="customer_credit_card_billing_address_region"
            label="State/Region"
          />
          <Input
            id="customer_credit_card_billing_address_region"
            maxLength="3"
            name="customer[credit_card][billing_address][region]"
            value={billingAddressData.state}
            onChange={(e) => onChangeBillingAddressData(e.currentTarget.value, 'state')}
          />
          <div className="col-md-6 col-md-offset-4">
            The 2 letter code for US states or an ISO-3166-2 country subdivision code of up to three letters. <strong>If unsure, leave blank</strong>
          </div>
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_country_name_input">
          <Label
            htmlFor="customer_credit_card_billing_address_country_name"
            label="Country"
            required
          />
          <select
            id="customer_credit_card_billing_address_country_name"
            className="form-control col-md-6"
            required
            name="customer[credit_card][billing_address][country_name]"
            value={selectValue}
            onChange={onSelectCountry}
          >
            <option value=""></option>
            { countriesList.map((country, i) => (
              <option
                key={`${country[1]}${i}`}
                value={country[1]}
              >
                {country[0]}
              </option>)
            )}
          </select>
        </ListItem>
      </ul>
    </>
  )
}

export { BraintreeBillingAddressFields }
