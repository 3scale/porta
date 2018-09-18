Raimon Grau


Table of Contents
_________________

1 Getting started
2 Detailed walkthrough
.. 2.1 Nginx.conf
..... 2.1.1 upstreams
..... 2.1.2 server sections
..... 2.1.3 location sections
..... 2.1.4 Nginx.lua
.. 2.2 Common edits
..... 2.2.1 Multiple services under same domain
..... 2.2.2 Using user_key as basic auth
.. 2.3 Customizations
..... 2.3.1 Activate customization
..... 2.3.2 Format of config.lua
.. 2.4 Deployment and maintenance
3 Resources


These configuration files will set up an Nginx instance as an API
Gateway that will use 3scale to authenticate incoming API calls.


1 Getting started
=================

  These are the basic changes you need to do in order to get your
  configuration up and running.

  #. drop these files into your Nginx configuration directory
     (e.g. /opt/openresty/nginx/conf).

  #. modify the server_name statement in your nginx.conf file to be the
  domain of your Nginx proxy (this step is only stricly necessary if you
  have more than one service in 3scale)

  #. start Nginx or reload Nginx (see Nginx on-premises setup guide in
  the Resources section)


2 Detailed walkthrough
======================

2.1 Nginx.conf
~~~~~~~~~~~~~~

2.1.1 upstreams
---------------

  These are the backend servers to which Nginx will be sending
  requests. There will always be:

  - One for each service you have in 3scale (your API backend servers)
  - An additional one pointing to the 3scale service management API


2.1.2 server sections
---------------------

  There is one server section for each service that you configure in
  your 3scale admin portal. Each server section acts as a different
  virtual host, allowing you to expose multiple domains/subdomains with
  one instance of Nginx.

  - server_name : Domain name of the virtual host. It is only required
    when there are more than one server sections.


2.1.3 location sections
-----------------------

  Within each server section you will find multiple location sections.


* 2.1.3.1 location /

  This is the main location and it is the point of entry for all
  incoming API requests. This section calls the Lua code in the
  nginx.lua file to authenticate the request and, if the authentication
  is successful, allows it to go through to the API backend.

  Some important configurations within the main location section:


  - access_by_lua: 'requires' your Lua configuration file in your server
    (e.g.  /opt/openresty/nginx/conf/nginx_12345.lua) and call the
    function 'access'.

  - proxy_pass: If the authentication performed during the
    *access_by_lua* step has been successful then this instruction will
    perform a pass through. The variable *$proxy_pass* will have been
    set to point to the correct upstream in the Lua code.


* 2.1.3.2 location /threescale_authrep

  This and any other location sections different than the main one
  (i.e. the one with the "/" path) are only used internally by Nginx
  itself when calling 3scale.


2.1.4 Nginx.lua
---------------

  This file contains the code that performs the authentication for all
  incoming API calls. This includes validations against what you have
  configured in your 3scale admin portal:

  - check that the request carries credentials in the expected location
    defined in 3scale
  - check that the URL path matches at least one of those defined in
    3scale
  - call 3scale to authorize the request
  - if the response is successful, keep the authorization result in a
    local cache and let the request go through
  - if the response is unsuccessful, block the request and return the
    appropriate error code to the client

  From all the code sections there are only a few you really need to
  know about. These parts are the only ones impacted when you modify
  your configuration options in the 3scale admin portal.

  1.**Error parameters**: These are the status code and error messages
  that a client will get in response in case their API call was
  unsuccessful. These parameters are configured from the proxy
  integration page for each one of your services.

  2.**Mappings**: For each one of your services there will also be a
  function in extract_usage key.

  This function is the output of the mapping rules section of the proxy
  integration page in the 3scale admin portal. It will parse the URL
  path of the incoming request and attempt to match it against the ones
  previously defined by you. For each successful match the corresponding
  method/metric will be added to the transaction that will be reported
  to 3scale.

  3.**Extracting credentials**

  Near the end of the nginx.lua file, there will be a snippet of code
  like the following for each one of your services:

  ,----
  | if ngx.var.service_id == '2555417709352' then
  |   local parameters = get_auth_params("headers", string.split(ngx.var.request, " ")[1] )
  |     service = service_2555417709352
  |     ngx.var.secret_token = service.secret_token
  |     params.user_key = parameters["user_key"]
  |     get_credentials_user_key(params , service_2555417709352)
  |     ngx.var.cached_key = "2555417709352" .. ":" .. params.user_key
  |     auth_strat = "1"
  |     ngx.var.service_id = "2555417709352"
  |     ngx.var.proxy_pass = "https://example.com"
  |     usage, matched_patterns = service:extract_usage(ngx.var.request)
  |  end
  `----

  This is the entry point of the code in this file, where the service
  will be identified by its **id** and then the corresponding helper
  functions will be called to perform the key verification and the URL
  matching.


2.2 Common edits
~~~~~~~~~~~~~~~~

2.2.1 Multiple services under same domain
-----------------------------------------

  By default, when you have multiple services in 3scale these are
  translated into multiple **server** sections in the nginx.conf
  file. Since in Nginx a server section is equivalent to a virtual host,
  this means that each server will require a different domain name to be
  set up (using the **server_name** statement).

  It is sometimes desirable to expose multiple 3scale services through a
  single domain (e.g. api.mycompany.com) and then use a path fragment to
  distinguish between them:

  - api.mycompany.com/firstapi/
  - api.mycompany.com/secondapi/

  This can be easily achieved by converting your configuration to have a
  single **server** section and one **location /apipath** section within
  it for each service. The steps to achieve this starting from a default
  configuration with two services would be:

  - copy the **location /** section from one server section to the other
    one
  - delete one server section so you only keep the one that now has two
    **location /** sections
  - you can tell apart both services by looking at its **$service_id**
    variable which is the id for that service in 3scale.
  - modify the paths of these root locations to be **location
    /service1** and **location /service2**


2.2.2 Using user_key as basic auth
----------------------------------

  If you want your API to require the credentials to be sent following
  the [Basic Auth]([http://tools.ietf.org/html/rfc2617#section-2])
  format you can do so with a very simple change.

  Before downloading your Nginx configuration files you should have set
  your authentication mode to **user_key** and the credentials location
  to **headers** in your 3scale admin portal. If that is not the case,
  you just need to change those settings and download the files again.

  Once the required settings are in place, you just need to replace one
  function from your **nginx.lua** configuration file.

  - locate the function named get_auth_params
  - replace it by the one in [this
    snippet]([http://codehub.3scale.net/nginx/lua/authentication/2014/08/11/ExtractingBasicAuthtoken/])

  Now you will be able to call your API by sending the credentials in
  the authorization headers:

  ,----
  | Authorization: Basic <user_key>
  `----


2.3 Customizations
~~~~~~~~~~~~~~~~~~

  Apicast offers a way to modify its behaviour through an external file
  that will be evaluated as lua code. The behaviour of the authorization
  and matching of mapping rules can be modified using this method.


2.3.1 Activate customization
----------------------------

  In the beginning of the file, change the value of custom_config to the
  filename to require.
  ,----
  | local custom_config = false
  `----

  ,----
  | local custom_config = "config"
  `----

  should load "config.lua"


2.3.2 Format of config.lua
--------------------------

  The configuration file should be a module which exports a function
  called setup.

  This 'setup' method will be called with the 'access' module as a
  parameter, allowing to get to the service configs, or overwriting the
  matching functions.

  - All request increments hits in 1. superceeds any proxy rule:
  ,----
  | return { setup = function(_M)  _M.extract_usage = function() return {hits = 1}, "hits" end }
  `----

  - Add a custom metric to all hits. appart from the normal ones
  ,----
  | return {
  |   setup = function(_M)
  |     ngx.log(0, "SETUPPING")
  |
  |     for k, v in pairs(_M) do
  |       if k:match('service_') then
  |
  |         local old_extract_usage =  _M[k].extract_usage
  |
  |         local new_one = function(service, request)
  |           local usage, log = old_extract_usage(service, request)
  |           usage.my_new_metric = 1
  |           return usage, log .. ", my_new_metric"
  |         end
  |
  |         _M[k].extract_usage = new_one
  |       end
  |     end
  |
  |     ngx.log(0, "SETUP FINISHED")
  |   end
  | }
  `----

  - Add optional slash to exact maching endpoints that end with dollar
  ,----
  | return {
  |   setup = function(_M)
  |     ngx.log(0, "SETUPPING")
  |
  |     for k, v in pairs(_M) do
  |       if k:match('service_') then
  |         for i,r in ipairs(v.rules) do
  |           r.pattern = r.pattern:gsub("%$", '\\/*$')
  |         end
  |       end
  |     end
  |     ngx.log(0, "SETUP FINISHED")
  |   end
  | }
  `----


2.4 Deployment and maintenance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  How to start Nginx:

  ,----
  | sudo /opt/openresty/nginx/sbin/nginx -p /opt/openresty/nginx/ -c /opt/openresty/nginx/conf/YOUR-CONFIG-FILE.conf
  `----

  How to stop it:

  ,----
  | sudo /opt/openresty/nginx/sbin/nginx -p /opt/openresty/nginx/ -c /opt/openresty/nginx/conf/YOUR-CONFIG-FILE.conf -s stop
  `----

  Reload (for example, after a change to the configuration):
  ,----
  | sudo /opt/openresty/nginx/sbin/nginx -p /opt/openresty/nginx/ -c /opt/openresty/nginx/conf/YOUR-CONFIG-FILE.conf -s reload
  `----

  **Note:** these commands assume that you installed the Openresty
    bundle to the `/opt/openresty/` directory.

  You can always get a new version of your Nginx configuration from your
  the proxy integration page in your 3scale admin portal.  A quicker
  alternative is to get it through an API call:

  ,----
  | curl -X GET "https://MYCOMPANY-admin.3scale.net/admin/api/nginx.zip?provider_key=PROVIDERKEY"
  `----

  If you are using the 3scale AWS AMI there is a built-in tool that
  makes this more convenient. You just need to run:

  ,----
  | download-3scale-config
  `----

  Check in the the resources section for a document with more
  information about deploying Nginx on your own server.


3 Resources
===========

  - [Nginx on-premises setup]
  - [Advanced settings for Nginx in 3scale]
  - [Useful tips for running the 3scale API gateway in production]


  [Nginx on-premises setup]
  https://support.3scale.net/docs/deployment-options/apicast-self-managed

  [Advanced settings for Nginx in 3scale]
  https://support.3scale.net/howtos/api-configuration#apicast-advanced-config

  [Useful tips for running the 3scale API gateway in production]
  https://support.3scale.net/howtos/api-configuration#production-tips-gateway
