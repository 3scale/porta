https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/app/javascript/src/ChangePassword/components/ChangePasswordHooks.jsx#L87

  This condition will always return 'false' since the types 'boolean' and 'string' have no overlap.ts(2367)

https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/app/javascript/src/ChangePassword/components/ChangePasswordHooks.jsx#L8
https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/app/javascript/src/ChangePassword/components/ChangePasswordHooks.jsx#L24

  Type '{ minimum: number; message: string; }' is not assignable to type 'ValidatorOption'.
  Object literal may only specify known properties, but 'minimum' does not exist in type 'ValidatorOption'. Did you mean to write 'minimun'?ts(2322)

https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/spec/javascripts/LoginPage/Login3scaleForm.spec.jsx#L40

  Cannot invoke an object which is possibly 'undefined'.ts(2722)

  Nota: esto es de hecho mal. onChange es opcional, entonces TS se queja. Lo ideal sería de alguna manera forzar un typo o decirle que onChange existe para el proposito de nuestro test, sin embargo no parece posible hacerlo de manera legible sin introducir 203224 casteos. La solucion más facil parece ser añadir un null-check y punto.
  UPDATE: resulta que el null check assertion '!' era la solucion correcta. Entonces eslint se queja pero ponemos un eslintrc para spec/javascripts deshabilitando esa regla y punto.

https://github.com/3scale/porta/blob/6a049b5184f93ccc4f8f8aff8bb85750c7dbdff3/app/javascript/packs/add_backend_usage.js#L1

  Para que funcione la herramienta de migración, el fichero debe usar @flow. Dentro de la carpeta packs tenemos muchos archivos que no lo usan, habrá que hacerlos a mano.

https://github.com/3scale/porta/blob/6a049b5184f93ccc4f8f8aff8bb85750c7dbdff3/app/javascript/src/BackendApis/components/DescriptionInput.jsx#L20

  Al copiar NameInput -> DescriptionInput la prop 'name' se cambio automáticamente por 'description', que no es una prop del input, además de romper el formulario porque el campo descripción nunca se envía. Flow pasó esto por alto completamente, TS no :)

https://github.com/3scale/porta/blob/6a049b5184f93ccc4f8f8aff8bb85750c7dbdff3/app/javascript/src/BackendApis/components/NewBackendModal.jsx#L45

  Usamos varias versiones de jQuery a lo largo del proyecto. Cual exactamente usa React? supondríamos que la instalada en el package.json (3.5) por lo tanto los types deben seguir esa versión. Al pasar a TS, salta un error en esta línea pues #live se reemplazó en jQuery v1.9 por #on. Sin embargo hay otro paquete, jquery-ui v.1.12 que podría tener algo que ver. Por qué entonces hay 2 paquetes de jQuery? Por averiguar... En cualquier caso hay que ver si este componente estaba fallando o si efectivamente #live funciona.
  TODO: averiguar versión exacta de jQuery en React

https://github.com/3scale/porta/blob/6a049b5184f93ccc4f8f8aff8bb85750c7dbdff3/app/javascript/src/Common/components/CompactListCard.jsx#L68

  Aquí se está pasando una funcion onSearch que no es compatible con onClick. Esto podría ser la razón por la que el useSearchEffect no funcione como debería. Flow lo pasó por alto. Habrá que investigar si funciona o no y por qué.

https://github.com/3scale/porta/blob/6a049b5184f93ccc4f8f8aff8bb85750c7dbdff3/app/javascript/src/BackendApis/components/NewBackendForm.jsx#L20

  errors es una prop opcional y de hecho tiene un valor por defecto {} para que no pete al llamar errors.private_endpoint. Al pasar a TS no obstante falla al transpilar pues '{}' no es compatible con 'errors: { private_endpoint: string[] }'. Pero es que tampoco parece entender que errors puede ser undefined y no lanza un error al llamar errors.private_endpoint, por lo tanto peta.
  TODO: buscar solucion, de alguna manera tiene que pitar y obligarte a hacer null assertion 'errors?.private_endpoint'
  SOLUCION: resulta que hay que activar 'strict: true' en el tsconfig.json. Se ve que este check no es strict... no lo habría imaginado

https://github.com/3scale/porta/blob/cbc214ef62a6643d4351fd3104be89f0572fd258/app/javascript/src/BackendApis/components/IndexPage.jsx#L63

  Hemos tenido mucho lio con le tema de la paginacion, los tipos number y string. En la consola de vez en cuando salen warnings debido a esto. Aunque al final da igual porque el number se convierte implicitamente a string, gracias a los types de Patternfly ahora podemos ver donde se originan estos warnings y usar el tipo (number vs string) adecuado.

https://github.com/3scale/porta/blob/89f60bd65cc7437607e79da678a96ac65a8d4083/app/javascript/src/Common/components/ToolbarSearch.jsx#L101-L114

  Este componente (Popover) no nos daba ningún problema con Flow y de hecho se renderizaba, aunque de forma rara. Al pasar a TS ahora nos da un fallo de compilación, diciendo que el tipo de retorno no es correcto. Muy extraño porque parece un problema de tipado pero no podemos subir la version de patternfly y (creo que) tampoco podemos instalar types más modernos.
  TODO: averiguar que coño pasa, he escrito en el Slack de Patternfly.
