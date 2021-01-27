import { SelectOptionObject } from '@patternfly/react-core'

type Plan = {
  id: string,
  name: string
}

class PlanSelectOptionObject implements SelectOptionObject {
  constructor (plan: Plan) {
    this.id = plan.id
    this.name = plan.name
  }

  toString (): string {
    return this.name
  }

  compareTo (plan: Plan): boolean {
    return plan.id === this.id
  }
}

export {PlanSelectOptionObject}
