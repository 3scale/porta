/* eslint-disable @typescript-eslint/naming-convention */

export type AccountData = Record<string, {
  name: string;
  value: string;
}[]>

export interface ApiDocsService {
  name: string;
  system_name: string;
  description: string;
  path: string;
  service_endpoint: string;
}

export interface ApiDocsServices {
  host: string;
  apis: ApiDocsService[];
}
