import type { FunctionComponent } from "react"

const HiddenServiceDiscoveryInput: FunctionComponent = () => (
  <input
    id="service_source"
    name="service[source]"
    type="hidden"
    value="discover"
  />
)

export { HiddenServiceDiscoveryInput }
