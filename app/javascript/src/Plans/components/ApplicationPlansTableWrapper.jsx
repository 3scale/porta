// @flow

import React from 'react'

// $FlowIgnore[missing-export] export is there, name_mapper is the problem
import { ApplicationPlansTable } from 'Plans'
import { createReactWrapper } from 'utilities/createReactWrapper'
import type { Props } from 'Plans/components/ApplicationPlansTable'

const PlansTableWrapper = (props: Props, containerId: string): void => createReactWrapper(<ApplicationPlansTable {...props} />, containerId)

export { PlansTableWrapper }
