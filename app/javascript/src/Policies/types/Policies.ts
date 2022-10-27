import type { JSONSchema6 } from 'json-schema'

export type Configuration = JSONSchema6

// Represents the data stored for @proxy.policies_config
export interface PolicyConfig {
  name: string;
  configuration: JSONSchema6;
  version: string;
  enabled: boolean;
}

// Represents policies of the Registry
export interface RegistryPolicy {
  $schema: string;
  schema?: JSONSchema6;
  configuration: JSONSchema6;
  description: string[]; // TODO: verify this prop is correctly typed
  name: string;
  summary: string;
  version: string;
  data?: Configuration;
  humanName: string;
}

// Represents policies stored in the Chain, once copied from the Registry
export type ChainPolicy = RegistryPolicy & {
  uuid: string;
  enabled: boolean;
  removable: boolean;
}
