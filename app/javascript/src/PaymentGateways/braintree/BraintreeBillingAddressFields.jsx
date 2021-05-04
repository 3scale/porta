import React, { useState } from 'react'
import { Label } from 'PaymentGateways'
const inputStyle = { width: '50%' }

const BraintreeBillingAddressFields = ({ countriesList, billingAddressData, setBillingAddressData, selectedCountryCode }) => {
  const [selectValue, setSelectValue] = useState(selectedCountryCode || '')

  const onChangeBillingAddressData = (value, field) => {
    setBillingAddressData({
      ...billingAddressData,
      [field]: value
    })
  }

  const onSelectCountry = (e) => {
    setSelectValue(e.target.value)
    onChangeBillingAddressData(e.target.options[e.target.selectedIndex].text, 'country')
  }

  return (
    <>
      <legend>Biling address</legend>
      <ul className="list-unstyled">
        <li
          id="customer_credit_card_billing_address_company_input"
          className="string optional form-group"
        >
          <Label
            htmlFor="customer_credit_card_billing_address_company"
            label="Company"
            required
          />
          <input
            type="text"
            className="form-control col-md-6"
            id="customer_credit_card_billing_address_company"
            required
            style={ inputStyle }
            name="customer[credit_card][billing_address][company]"
            value={billingAddressData.company}
            onChange={(e) => onChangeBillingAddressData(e.target.value, 'company')}
          />
        </li>
        <li
          id="customer_credit_card_billing_address_street_address_input"
          className="string optional form-group"
        >
          <Label
            htmlFor="customer_credit_card_billing_address_street_address"
            label="Street address"
            required
          />
          <input
            type="text"
            className="form-control col-md-6"
            id="customer_credit_card_billing_address_street_address"
            required
            style={ inputStyle }
            name="customer[credit_card][billing_address][street_address]"
            value={billingAddressData.address1}
            onChange={(e) => onChangeBillingAddressData(e.target.value, 'address1')}
          />
        </li>
        <li
          id="customer_credit_card_billing_address_postal_code_input"
          className="string optional form-group"
        >
          <Label
            htmlFor="customer_credit_card_billing_address_postal_code"
            label="ZIP / Postal Code"
            required
          />
          <input
            type="text"
            className="form-control col-md-6"
            id="customer_credit_card_billing_address_postal_code"
            required
            style={ inputStyle }
            name="customer[credit_card][billing_address][postal_code]"
            value={billingAddressData.zip}
            onChange={(e) => onChangeBillingAddressData(e.target.value, 'zip')}
          />
        </li>
        <li
          id="customer_credit_card_billing_address_locality_input"
          className="string optional form-group"
        >
          <Label
            htmlFor="customer_credit_card_billing_address_locality"
            label="City"
            required
          />
          <input
            type="text"
            className="form-control col-md-6"
            id="customer_credit_card_billing_address_locality"
            required
            style={ inputStyle }
            name="customer[credit_card][billing_address][locality]"
            value={billingAddressData.city}
            onChange={(e) => onChangeBillingAddressData(e.target.value, 'city')}
          />
        </li>
        <li
          id="customer_credit_card_billing_address_region_input"
          className="string optional form-group"
        >
          <Label
            htmlFor="customer_credit_card_billing_address_region"
            label="State/Region"
          />
          <input
            type="text"
            className="form-control col-md-6"
            id="customer_credit_card_billing_address_region"
            maxLength="3"
            style={ inputStyle }
            name="customer[credit_card][billing_address][region]"
            value={billingAddressData.state}
            onChange={(e) => onChangeBillingAddressData(e.target.value, 'state')}
          />
          <div className="col-md-6 col-md-offset-4">
            The 2 letter code for US states or an ISO-3166-2 country subdivision code of up to three letters. <strong>If unsure, left blank</strong>
          </div>
        </li>
        <li
          id="customer_credit_card_billing_address_country_name_input"
          className="string optional form-group"
        >
          <Label
            htmlFor="customer_credit_card_billing_address_country_name"
            label="Country"
          />
          <select
            id="customer_credit_card_billing_address_country_name"
            className="form-control col-md-6"
            required
            style={ inputStyle }
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
        </li>
      </ul>
    </>
  )
}

export { BraintreeBillingAddressFields }
