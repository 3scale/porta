import { register } from 'fishery'
import { Application } from 'tests/factories/applications'
import { DeveloperAccount } from 'tests/factories/developer-account'
import { Plan } from 'tests/factories/plan'
import { Product } from 'tests/factories/product'

export const factories = register({
  Product,
  Plan,
  Application,
  DeveloperAccount
})
