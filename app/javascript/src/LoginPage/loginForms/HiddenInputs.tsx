import { CSRFToken } from 'utilities'

const HiddenInputs = (
  {
    isPasswordReset = false
  }: {
    isPasswordReset?: boolean
  }
): React.ReactElement => {
  return (
    <>
      <input name="utf8" type="hidden" value="✓" />
      {isPasswordReset ? <input name="_method" type="hidden" value="delete" /> : null}
      <CSRFToken />
    </>
  )
}

export {
  HiddenInputs
}
