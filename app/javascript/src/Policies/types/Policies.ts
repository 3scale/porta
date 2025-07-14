import type { JSONSchema7 } from 'json-schema'
import type { RJSFSchema } from '@rjsf/utils'

// Represents the data stored for @proxy.policies_config
export interface PolicyConfig {
  name: string;
  configuration: JSONSchema7;
  version: string;
  enabled: boolean;
}

// Represents policies of the Registry
export interface RegistryPolicy {
  $schema: string;
  schema?: RJSFSchema;
  configuration: JSONSchema7;
  description: string[]; // TODO: verify this prop is correctly typed
  name: string;
  summary: string;
  version: string;
  data?: JSONSchema7;
  humanName: string;
}

// Represents policies stored in the Chain, once copied from the Registry
export type ChainPolicy = RegistryPolicy & {
  uuid: string;
  enabled: boolean;
  removable: boolean;
}
