import type { FunctionComponent } from 'react'

interface Props {
  name: string;
  id: string;
  disabled?: boolean;
  onChange?: (event: React.SyntheticEvent<HTMLSelectElement>) => void;
  options: string[];
}

const Select: FunctionComponent<Props> = ({
  name,
  id,
  disabled,
  onChange,
  options
}) => (
  <select
    required
    disabled={disabled}
    id={id}
    name={name}
    onChange={onChange}
  >
    {options.map((option) => <option key={option} value={option}>{option}</option>)}
  </select>
)

export type { Props }
export { Select }
