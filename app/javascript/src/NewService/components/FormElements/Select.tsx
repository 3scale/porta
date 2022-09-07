import * as React from 'react';

type Props = {
  name: string,
  id: string,
  disabled?: boolean,
  onChange?: (event: React.SyntheticEvent<HTMLSelectElement>) => void,
  options: Array<string>
};

const Options = ({options}) => {
  return options.map((option) => {
    return <option key={option} value={option}>{option}</option>
  })
}

const Select = (
  {
    name,
    id,
    disabled,
    onChange,
    options,
  }: Props,
): React.ReactElement => <select
  required="required"
  name={name}
  id={id}
  disabled={disabled}
  onChange={onChange}
>
  <Options options={options}/>
</select>

export {Select}
