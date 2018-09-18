module Apicast
  GENERATORS = [
    Apicast::LuaAuthorizeGenerator,
    Apicast::LuaGetTokenGenerator,
    Apicast::LuaThreescaleUtilsGenerator,
    Apicast::LuaAuthorizedCallbackGenerator
  ].map(&:new).freeze
end
