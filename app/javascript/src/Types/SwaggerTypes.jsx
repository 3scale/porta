export type Primitive = string | number | boolean

export type ServiceHosts = Array<{ name: string, value: string }>

export type AccountData = {
 [string]: Array<{ name: string, value: string }>
}

export type ParamArraySchema = {
 type: 'array',
 items: { type: Primitive }
}
export type ParamEnumSchema = {
 enum: Array<Primitive>,
 items: { type: Primitive }
}

export type Examples = Array<{
 summary: string,
 value: string
}>

export type Param = {
 in: string,
 name: string,
 description?: string,
 required?: boolean,
 schema?: Primitive | ParamArraySchema | ParamEnumSchema,
 examples?: Examples
}

export type ResponseBody = {
 paths: {
   [string]: {
     parameters: Array<Param>,
     [string]: string | {}
   }
 },
 [string]: string | {}
}

export type SwaggerResponse = {
 body: ResponseBody,
 data: string,
 headers: {},
 obj: {},
 ok: boolean,
 status: number,
 statusText: string,
 text: string,
 url: string
}
