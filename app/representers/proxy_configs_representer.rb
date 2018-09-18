module ProxyConfigsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :proxy_configs
  items extend: ProxyConfigRepresenter
end
