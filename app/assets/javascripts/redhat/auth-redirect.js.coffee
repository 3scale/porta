parse_key_value_pairs = (str, sep) ->
  sep ||= '&'
  pairs = (pair.split '=' for pair in (str.split sep))
  params = {}
  params[pair[0]] = pair[1] for pair in pairs
  params

get_query_string_params = ->
  parse_key_value_pairs window.location.search.substring(1)

get_fragment_params = () ->
  parse_key_value_pairs window.location.hash.substring(1)

tap = (o, fn) -> fn(o); o

merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs

json_to_query = (obj) ->
  Object.keys(obj).map((k)->
    encodeURIComponent(k) + '=' + encodeURIComponent(obj[k])
  ).join('&')

callback_url = () ->
  params = merge(get_query_string_params(), get_fragment_params())

  scheme = window.location.protocol
  domain = params.self_domain
  port = window.location.port

  delete params.self_domain
  delete params.scope

  "#{scheme}//#{domain}:#{port}/p/admin/auth/redhat-customer-portal/callback?#{json_to_query(params)}"

window.location.replace(callback_url())