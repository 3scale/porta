import React, { FunctionComponent } from 'react'

type Props = {
  htmlFor: string,
  label: string,
  required?: boolean
};

const Label: FunctionComponent<Props> = ({
  htmlFor,
  label,
  required
}) => <label
  htmlFor={htmlFor}
  className="col-md-4 control-label"
>
  {`${label}${required ? ' *' : ''}`}
</label>

export { Label, Props }
