// There are no official types for swagger-client. These has been inspired by:
// - https://github.com/swagger-api/swagger-js/blob/master/src/execute/index.js
declare module 'swagger-client/es/execute' {

  type SupportedHTTPMethods = 'delete' | 'get' | 'head' | 'options' | 'patch' | 'post' | 'put' | 'trace'

  type Response = Record<string, unknown>

  type Request = Record<string, unknown>

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

  interface SwaggerUI {

    /**
     * Provide Swagger UI with information about your OAuth server - see the
     * OAuth 2.0 documentation for more information.
     *
     * @param options
     */
    initOAuth: (options: unknown) => void;

    /**
     * Programmatically set values for a Basic authorization scheme.
     *
     * @param authDefinitionKey
     * @param username
     * @param password
     */
    preauthorizeBasic: (authDefinitionKey: unknown, username: unknown, password: unknown) => unknown;

    /**
     * Programmatically set values for an API key or Bearer authorization scheme.
     * In case of OpenAPI 3.0 Bearer scheme, apiKeyValue must contain just the token
     * itself without the Bearer prefix.
     *
     * @param authDefinitionKey
     * @param apiKeyValue
     */
    preauthorizeApiKey: (authDefinitionKey: unknown, apiKeyValue: unknown) => unknown;
  }
}
