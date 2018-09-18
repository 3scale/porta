SwaggerDoc::Application.routes.draw do
  root :to => 'resources#home'
  resources :resources

  match 'api_docs/track.:format' => 'track#show'
  match 'preview' => "resources#preview"

  match 'api' => 'api#index'

  match '/api_docs/services.:format' => 'services#index'
  match '/api_docs/:id.:format' => 'services#show'
end
