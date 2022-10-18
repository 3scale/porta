import type { FunctionComponent } from 'react'

type Props = {
  htmlFor: string,
  label: string,
  required?: boolean
}

const Label: FunctionComponent<Props> = ({
  htmlFor,
  label,
  required
}) => (
  <label className="col-md-4 control-label" htmlFor={htmlFor}>
    {`${label}${required ? ' *' : ''}`}
  </label>
)

export { Label, Props }
