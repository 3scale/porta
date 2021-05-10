import { ChangePasswordWrapper as ChangePassword } from 'ChangePassword'
import { safeFromJsonString } from 'utilities'

document.addEventListener('DOMContentLoaded', () => {
  const changePasswordContainer = document.getElementById('pf-login-page-container')
  const changePasswordProps = safeFromJsonString(changePasswordContainer.dataset.changePasswordProps)
  ChangePassword(changePasswordProps, 'pf-login-page-container')
})
