import React from 'react'
import type { ReactNode } from 'react'
import type { BraintreeSubmitFieldsProps } from 'PaymentGateways'

const BraintreeSubmitFields = (
  {
    onSubmitForm,
    isFormValid
  }: BraintreeSubmitFieldsProps
): Node => {
  return (
    <div className="form-group">
      <div className="col-md-10 operations">
        <button
          className="btn btn-primary pull-right"
          onClick={onSubmitForm}
          disabled={!isFormValid}
        >
          Save details
        </button>
      </div>
    </div>
  )
}

export { BraintreeSubmitFields }
