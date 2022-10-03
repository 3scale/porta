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
      <input name="utf8" type="hidden" value="✓"/>
      {isPasswordReset && <input type="hidden" name="_method" value="delete"/>}
      <CSRFToken/>
    </>
  )
}

export {
  HiddenInputs
}
