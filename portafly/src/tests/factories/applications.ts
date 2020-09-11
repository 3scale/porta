import { Factory } from 'fishery'
import { IApplication } from 'types'

const Application = Factory.define<IApplication>(({ sequence }) => ({
  id: sequence,
  name: `Cool App ${sequence}`,
  state: 'live',
  account: {
    id: sequence,
    orgName: `Ramdon Org ${sequence}`
  },
  plan: {
    id: sequence,
    name: `Super Plan ${sequence}`
  },
  created_on: `2020-06-01T00:00:0${sequence}Z`,
  traffic_on: `2020-06-01T00:00:0${sequence}Z`
}))

export { Application }
