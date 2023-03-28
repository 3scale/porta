import type { FunctionComponent } from 'react'

interface Props {
  fetchErrorMessage: string;
}

const ErrorMessage: FunctionComponent<Props> = ({ fetchErrorMessage }) => (
  <p className="errorMessage">
    {`Sorry, your request has failed with the error: ${fetchErrorMessage}`}
  </p>
)

export type { Props }
export { ErrorMessage }
