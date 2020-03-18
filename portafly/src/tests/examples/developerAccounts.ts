import { factories } from 'tests/factories'
import { IDeveloperAccount } from 'types'

export const developerAccounts: IDeveloperAccount[] = ['Josemi', 'Damian'].map((name) => (
  factories.DeveloperAccount.build({
    admin_name: name,
    org_name: `${name}'s Corp.`
  })
))
