Geigercrowd::Application.routes.draw do
  resources :data_types
  resources :locations
  resources :users do
    resources :instruments do
      resources :samples
    end
  end
  
  devise_for :users
  root :to => "welcome#index"
  match "instruments(/:option)" => "instruments#list"
  match "samples(/:option)" => "samples#list"
  match "api" => "welcome#api"
  match "api/public" => "welcome#api_public"
  match "api/private" => "welcome#api_private"
end
