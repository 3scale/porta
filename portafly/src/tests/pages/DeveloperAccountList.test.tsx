import { factories } from 'tests/factories'
import { IDeveloperAccount } from 'types'

// TODO: Replace this pseudo test with a more meaningful Developer Account List test.
const devAccounts: IDeveloperAccount[] = ['Josemi', 'Damian'].map((name) => (
  factories.DeveloperAccount.build({
    admin_name: name,
    org_name: `${name}'s Corp.`
  })
))

it("Look Ma, I'm testing using factories!", () => {
  expect(devAccounts[0].org_name).toBe("Josemi's Corp.")
})
