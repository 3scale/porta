// @flow

import * as React from 'react'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { Form } from 'Settings/components/Form'
import { SETTINGS_DEFAULT } from 'Settings/defaults'
import type { SettingsProps } from 'Settings/types'

type Props = {
  settings: SettingsProps,
  elementId: string
}

const initSettings = ({
  settings = SETTINGS_DEFAULT,
  elementId
}: Props) => createReactWrapper(<Form {...settings} />, elementId)

export {
  initSettings
}
