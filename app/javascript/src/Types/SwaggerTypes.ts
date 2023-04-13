/* eslint-disable @typescript-eslint/naming-convention */
import type { Request, Response, SupportedHTTPMethods } from 'swagger-ui'

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

export interface ExecuteData {
  contextUrl: string;
  fetch: (arg: unknown) => unknown;
  method: SupportedHTTPMethods;
  operation: unknown;
  operationId: string;
  parameters: unknown;
  pathName: string;
  requestBody?: unknown;
  requestContentType: string;
  requestInterceptor?: ((request: Request) => Promise<Request> | Request) | undefined;
  responseContentType: string;
  responseInterceptor?: ((response: Response) => Promise<Response> | Response) | undefined;
  scheme: string;
  securities: unknown;
  server: string;
  serverVariables: unknown;
  spec: unknown;
}

export interface BackendApiTransaction extends BodyValueObject {
  app_id?: string;
  user_key?: string;
  timestamp?: string;
  usage: Record<string, number>;
  log?: {
    request?: string;
    response?: string;
    code?: string;
  };
}

export interface BackendApiReportBody extends BodyValueObject {
  service_token?: string;
  service_id?: string;
  transactions?: (BackendApiTransaction | string)[];
}

/**
 * when using Record notation, the following error is thrown:
 * 'TS2456: Type alias 'BodyValue' circularly references itself.'
 */
export type BodyValue = BodyValue[] | boolean | number | string | { [key: string]: BodyValue } | null | undefined
export type BodyValueObject = Record<string, BodyValue>

export type FormData = Record<string, boolean | number | string>
