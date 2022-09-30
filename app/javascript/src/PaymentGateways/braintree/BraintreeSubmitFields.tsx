import { FunctionComponent } from 'react'

type Props = {
  onSubmitForm: (event: React.MouseEvent<HTMLButtonElement>) => Promise<unknown> | undefined,
  isFormValid: boolean
}

const BraintreeSubmitFields: FunctionComponent<Props> = ({
  onSubmitForm,
  isFormValid
}) => (
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

export { BraintreeSubmitFields, Props }
