Foursweep::Application.routes.draw do
  match "(*any)",
    to: redirect(subdomain: ""),
    via: :all,
    constraints: { subdomain: "www" }

  match "changes" => 'changelog#changes', via: [:get, :post]

  match "stats/" => 'stats#stats', via: [:get, :post]

  match "stats/:user_id" => 'stats#stats', via: [:get, :post]
  match "category_changes" => 'stats#category_changes', via: [:get, :post]

  match "about" => 'static_pages#about', via: [:get, :post]
  match "about/faq" => 'static_pages#faq', via: [:get, :post]
  match "about/changelog" => 'static_pages#changelog', via: [:get, :post]
  match "about/contact" => 'static_pages#contact', via: [:get, :post]
  match "about/suggestion" => 'static_pages#suggestion', via: [:get, :post]

  match 'heartbeat' => 'heartbeat#heartbeat', via: [:get, :post]
  get "flags/list"
  get "flags/check"
  get "flags/newcount"
  match "flags/statuses", via: [:get, :post]
  match 'flags/run' => 'flags#run', :via=>:post
  match 'flags/resubmit' => 'flags#resubmit', :via=>:post
  match 'flags/hide' => 'flags#hide', :via=>:post
  match 'flags/check' => 'flags#check', via: [:get, :post]
  match 'flags/cancel' => 'flags#cancel', via: [:get, :post]

  get "explorer/explore"

  get "session/callback"
  get "session/error"
  get "session/new"
  get "session/logout"
  get "session/not_allowed"

  resources :flags

  root :to => 'explorer#explore'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
