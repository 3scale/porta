import { useState } from 'react'

import { ListItem } from 'PaymentGateways/braintree/components/ListItem'
import { Label } from 'PaymentGateways/braintree/components/Label'
import { Input } from 'PaymentGateways/braintree/components/Input'

import type { ChangeEventHandler, FunctionComponent } from 'react'
import type { BillingAddressData } from 'PaymentGateways/braintree/types'

interface Props {
  countriesList: string[][];
  billingAddressData: BillingAddressData;
  setBillingAddressData: (obj: BillingAddressData) => void;
  selectedCountryCode: string;
}

const BraintreeBillingAddressFields: FunctionComponent<Props> = ({
  countriesList,
  billingAddressData,
  setBillingAddressData,
  selectedCountryCode = ''
}) => {
  const [selectValue, setSelectValue] = useState(selectedCountryCode)

  const onChangeBillingAddressData = (value: string, field: string) => {
    setBillingAddressData({
      ...billingAddressData,
      [field]: value
    })
  }

  const onSelectCountry: ChangeEventHandler<HTMLSelectElement> = (e) => {
    setSelectValue(e.currentTarget.value)
    onChangeBillingAddressData(e.currentTarget.options[e.currentTarget.selectedIndex].text, 'country')
  }

  return (
    <>
      <legend>Billing address</legend>
      <ul className="list-unstyled">
        <ListItem id="customer_credit_card_billing_address_company_input">
          <Label
            required
            htmlFor="customer_credit_card_billing_address_company"
            label="Company"
          />
          <Input
            required
            id="customer_credit_card_billing_address_company"
            name="customer[credit_card][billing_address][company]"
            value={billingAddressData.company}
            onChange={(e) => { onChangeBillingAddressData(e.currentTarget.value, 'company') }}
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_street_address_input">
          <Label
            required
            htmlFor="customer_credit_card_billing_address_street_address"
            label="Street address"
          />
          <Input
            required
            id="customer_credit_card_billing_address_street_address"
            name="customer[credit_card][billing_address][street_address]"
            value={billingAddressData.address1}
            onChange={(e) => { onChangeBillingAddressData(e.currentTarget.value, 'address1') }}
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_postal_code_input">
          <Label
            required
            htmlFor="customer_credit_card_billing_address_postal_code"
            label="ZIP / Postal Code"
          />
          <Input
            required
            id="customer_credit_card_billing_address_postal_code"
            name="customer[credit_card][billing_address][postal_code]"
            value={billingAddressData.zip}
            onChange={(e) => { onChangeBillingAddressData(e.currentTarget.value, 'zip') }}
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_locality_input">
          <Label
            required
            htmlFor="customer_credit_card_billing_address_locality"
            label="City"
          />
          <Input
            required
            id="customer_credit_card_billing_address_locality"
            name="customer[credit_card][billing_address][locality]"
            value={billingAddressData.city}
            onChange={(e) => { onChangeBillingAddressData(e.currentTarget.value, 'city') }}
          />
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_region_input">
          <Label
            htmlFor="customer_credit_card_billing_address_region"
            label="State/Region"
          />
          <Input
            id="customer_credit_card_billing_address_region"
            name="customer[credit_card][billing_address][region]"
            value={billingAddressData.state}
            onChange={(e) => { onChangeBillingAddressData(e.currentTarget.value, 'state') }}
          />
          <div className="col-md-6 col-md-offset-4">
            The 2 letter code for US states or an ISO-3166-2 country subdivision code of up to three letters. <strong>If unsure, leave blank</strong>
          </div>
        </ListItem>
        <ListItem id="customer_credit_card_billing_address_country_name_input">
          <Label
            required
            htmlFor="customer_credit_card_billing_address_country_name"
            label="Country"
          />
          <select
            required
            className="form-control col-md-6"
            id="customer_credit_card_billing_address_country_name"
            name="customer[credit_card][billing_address][country_name]"
            value={selectValue}
            onChange={onSelectCountry}
          >
            <option value="" />
            {countriesList.map(country => (
              <option key={country[1]} value={country[1]}>
                {country[0]}
              </option>
            ))}
          </select>
        </ListItem>
      </ul>
    </>
  )
}

export { BraintreeBillingAddressFields, Props }
