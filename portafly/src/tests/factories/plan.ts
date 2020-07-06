import { Factory } from 'fishery'
import { IPlan } from 'types'

const Plan = Factory.define<IPlan>(({ sequence }) => ({
  id: sequence,
  name: 'Basic Plan'
}))

export { Plan }
