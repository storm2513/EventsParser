
Rails.application.routes.draw do
	require 'sidekiq/web'
	mount Sidekiq::Web => '/sidekiq'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/" => "main#index"
  get "/version" => "main#version"
  get "/count" => "main#count"
  get "/update" => "main#update"
  get "/debug" => "main#debug"
end
