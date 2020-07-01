import { register } from 'fishery'
import { Application } from 'tests/factories/applications'
import { DeveloperAccount } from 'tests/factories/developer-account'
import { Plan } from 'tests/factories/plan'

export const factories = register({
  Plan,
  Application,
  DeveloperAccount
})
