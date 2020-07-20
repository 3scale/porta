/* eslint-disable import/no-extraneous-dependencies */

import * as React from 'react'
import { render, RenderOptions } from '@testing-library/react'
import { MemoryRouter, MemoryRouterProps } from 'react-router'
import '@testing-library/jest-dom/extend-expect'
import { LastLocationProvider } from 'react-router-last-location'

export interface ICustomRenderOptions extends Omit<RenderOptions, 'queries'> {
  router?: MemoryRouterProps
}

const customRender = (
  ui: React.ReactElement,
  options?: ICustomRenderOptions
) => {
  const AllTheProviders: React.FunctionComponent<ICustomRenderOptions> = ({
    children
  }) => {
    const { router } = options || {}
    return (
      // eslint-disable-next-line react/jsx-props-no-spreading
      <MemoryRouter {...router}>
        <LastLocationProvider>{children}</LastLocationProvider>
      </MemoryRouter>
    )
  }
  return render(ui, { wrapper: AllTheProviders, ...options })
}

export { customRender as render }
