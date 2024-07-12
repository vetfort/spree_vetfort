Spree::Core::Engine.add_routes do
  resources :links, only: [:index], controller: 'spree_vetfort/links'

  namespace :admin do
    namespace :spree_vetfort do
      resources :offline, only: [:new] do
        member do
          get :cart
          put :approve
        end
      end
    end
  end

  namespace :api do
    namespace :payments do
      resources :paynet, only: [] do
        collection do
          post :callback
        end
      end
    end
  end
end
