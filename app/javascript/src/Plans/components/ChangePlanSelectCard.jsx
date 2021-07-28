// @flow

import * as React from 'react'

import { createReactWrapper } from 'utilities'

import './DefaultPlanSelect.scss'

type Props = {
  // props here
}

const ChangePlanSelectCard = (props: Props): React.Node => {
  // logic here

  return (
    <div>ChangePlanSelectCard</div>
  )
}

const ChangePlanSelectCardWrapper = (props: Props, containerId: string): void => createReactWrapper(<ChangePlanSelectCard {...props} />, containerId)

export { ChangePlanSelectCard, ChangePlanSelectCardWrapper }
