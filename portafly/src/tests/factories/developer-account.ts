import { Factory } from 'fishery'
import { IDeveloperAccount } from 'types'

const DeveloperAccount = Factory.define<IDeveloperAccount>(({ sequence }) => ({
  admin_name: 'Oswell E. Spencer',
  apps_count: 3,
  created_at: '2019-10-18T05:13:26Z',
  id: sequence,
  org_name: 'Umbrella Corp.',
  state: 'approved',
  updated_at: '2019-10-18T05:13:27Z'
}))

export { DeveloperAccount }
