// There are no official types for swagger-client. These has been inspired by:
// - https://github.com/swagger-api/swagger-js/blob/master/src/execute/index.js
declare module 'swagger-client/es/execute' {
  import type { Request, Response, SupportedHTTPMethods } from 'swagger-ui'

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
  function execute (req: ExecuteData): unknown
  export { execute }
}
