import { factories } from 'tests/factories'
import { IDeveloperAccount } from 'types'

export const developerAccounts: IDeveloperAccount[] = ['Josemi', 'Damian'].map((name) => (
  factories.DeveloperAccount.build({
    adminName: name,
    orgName: `${name}'s Corp.`
  })
))
