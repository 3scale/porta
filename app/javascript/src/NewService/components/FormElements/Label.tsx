import type { FunctionComponent } from 'react'

interface Props {
  htmlFor: string;
  label: string;
  required?: boolean;
}

const Label: FunctionComponent<Props> = ({ htmlFor, label, required }) => (
  <label htmlFor={htmlFor}>{label}
    {required && <abbr title="required">*</abbr>}
  </label>
)

export type { Props }
export { Label }
