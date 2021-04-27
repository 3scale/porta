import React from 'react'

const BraintreeSubmitFields = ({ onSubmitForm, isFormValid }) => {
  return (
    <div className="form-group">
      <div className="col-md-10 operations">
        <button
          className="btn btn-primary pull-right"
          onClick={onSubmitForm}
          disabled={!isFormValid}
        >Save details</button>
      </div>
    </div>
  )
}

export { BraintreeSubmitFields }
