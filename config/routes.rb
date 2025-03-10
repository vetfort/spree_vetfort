Spree::Core::Engine.add_routes do
  resources :links, only: [:index], controller: 'spree_vetfort/links'

  namespace :admin do
    resources :admin_actions, only: [:index]
    namespace :spree_vetfort do
      resources :offline, only: [:new] do
        member do
          get :cart
          put :approve
        end
      end

      resources :properties_translations, only: [:update]

      resources :imports, only: %i[new create] do
        collection do
          get :template
        end
      end
    end
  end
end
