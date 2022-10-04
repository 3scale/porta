export type Configuration = any

// Represents the data stored for @proxy.policies_config
export type PolicyConfig = {
  name: string,
  configuration: Configuration,
  version: string,
  enabled: boolean
}

// Represents policies of the Registry
export type RegistryPolicy = {
  $schema: string,
  schema?: any
  configuration: Configuration,
  description: string[], // TODO: verify this prop is correctly typed
  name: string,
  summary: string,
  version: string,
  data?: Configuration,
  humanName: string
}

// Represents policies stored in the Chain, once copied from the Registry
export type ChainPolicy = RegistryPolicy & {
  uuid: string,
  enabled: boolean,
  removable: boolean
}
