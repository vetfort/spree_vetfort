# Spree::Core::Engine.add_routes do
#   namespace :admin do
#     namespace :spree_vetfort do
#       resources :orders, only: [] do
#         member do
#           get 'cart', to: 'offline#cart'
#         end
#       end
#       resource :offline, only: [:new, :create, :edit, :update]
#     end
#   end
# end
Spree::Core::Engine.add_routes do
  namespace :admin do
    namespace :spree_vetfort do
      # resources :orders, only: [] do
      #   member do
      #     get 'cart', to: 'offline#cart'
      #   end
      # end
      resources :offline, only: [:new] do
        member do
          get :cart
          put :approve
        end
      end
    end
  end
end
