# Rails.application.routes.draw do
#   # mount_devise_token_auth_for 'User', at: 'auth'
  
#     namespace :v1 domount_devise_token_auth_for "User", at: "auth", controllers: {
#       registrations: "auth/registrations"
# }

#   namespace :v1 do
#     # v1 以下に API を作るならここに書く
#     # resources :posts
#     # resources :users
#   end

#   # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

#   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
#   # Can be used by load balancers and uptime monitors to verify that the app is live.
#   get "up" => "rails/health#show", as: :rails_health_check

#   # Defines the root path route ("/")
#   # root "posts#index"
# end
# Rails.application.routes.draw do
#   namespace :api do
#     namespace :v1 do
#       mount_devise_token_auth_for "User", at: "auth", controllers: {
#         registrations: "api/v1/auth/registrations"
#       }
#       resources :plans, only: [:create, :index, :show, :update]
#       resources :groups
#     end
#   end
# end
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for "User", at: "auth", controllers: {
        registrations: "api/v1/auth/registrations"
      }

      resources :groups do
        resources :plans, only: [:index, :create]
      end

      resources :plans, only: [:show, :update]
      post 'groups/join', to: 'groups#join'
      get 'groups/:id/share_token', to: 'groups#share_token'
    end
  end
end


#   get "up" => "rails/health#show", as: :rails_health_check
# end
