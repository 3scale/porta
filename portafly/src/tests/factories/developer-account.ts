import { Factory } from 'fishery'
import { IDeveloperAccount } from 'types'

const DeveloperAccount = Factory.define<IDeveloperAccount>(({ sequence }) => ({
  adminName: 'Oswell E. Spencer',
  appsCount: 3,
  createdAt: '2019-10-18T05:13:26Z',
  id: sequence,
  orgName: 'Umbrella Corp.',
  state: 'approved',
  updatedAt: '2019-10-18T05:13:27Z'
}))

export { DeveloperAccount }
