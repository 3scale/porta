// @flow

import { SelectOptionObject } from '@patternfly/react-core'

type Plan = {
  id: number,
  name: string
}

class PlanSelectOptionObject implements SelectOptionObject {
  id: number
  name: string

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
