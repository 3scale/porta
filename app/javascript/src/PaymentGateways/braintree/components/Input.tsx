import { FunctionComponent } from 'react'

type Props = {
  id: string,
  required?: boolean,
  name: string,
  value: string,
  onChange?: (event: React.SyntheticEvent<HTMLInputElement>) => void
};

const Input: FunctionComponent<Props> = ({
  id,
  required = false,
  name,
  value,
  onChange
}) => <input
  id={id}
  required={required}
  name={name}
  value={value}
  onChange={onChange}
  className="col-md-6 form-control"
  type="text"
/>

export { Input, Props }
