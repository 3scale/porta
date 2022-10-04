import type { FunctionComponent } from 'react'

type Props = {
  id: string,
  required?: boolean,
  name: string,
  value: string,
  onChange?: (event: React.SyntheticEvent<HTMLInputElement>) => void
}

const Input: FunctionComponent<Props> = ({
  id,
  required = false,
  name,
  value,
  onChange
}) => (
  <input
    className="col-md-6 form-control"
    id={id}
    name={name}
    required={required}
    type="text"
    value={value}
    onChange={onChange}
  />
)

export { Input, Props }
