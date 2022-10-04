
type Props = {
  htmlFor: string,
  label: string,
  required?: boolean
}
const Label = (props: Props): React.ReactElement => {
  const { htmlFor, label, required } = props
  return (
    <label htmlFor={htmlFor}>{label}
      {required ? <abbr title="required">*</abbr> : null}
    </label>
  )
}

export { Label }
