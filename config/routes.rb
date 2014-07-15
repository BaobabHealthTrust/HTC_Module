HTCModule::Application.routes.draw do
  get "reports/index"
	get "/login" => "sessions#attempt_login"
	post "/login" => "sessions#login", as: :log_in
	get "/logout" => "sessions#logout", as: :log_out

	get "search" => "clients#search"
	post "search" => "clients#search"

	get "client_demographics" => "clients#demographics"
	post "client_demographics" => "clients#demographics"  

	#get "assign_client_to_unlocated_list" => "clients#assign_to_unlocated_list"
  get "clients/:id/add_to_unallocated" => "clients#add_to_unallocated", as: :add_to_unallocated
	post "encounters/new/:id" => "encounters#new", as: :new
  #post "assign_to_unlocated" => "clients#assign_to_unlocated"

  #get '/assign_to_unlocated_list/:id', to: 'clients#assign_to_unlocated_list'

	get "client_counseling" => "clients#counseling"
	post "client_counseling" => "clients#counseling"

	get "client_testing" => "clients#testing"
	post "client_testing" => "clients#testing"

	get "client_previous_visit" => "clients#previous_visit"
	post "client_previous_visit" => "clients#previous_visit"

	get "client_current_visit" => "clients#current_visit"
	post "client_current_visit" => "clients#current_visit"
	
	get "unallocated_clients" => "clients#unallocated_clients"
	#post "unallocated_clients" => "clients#unallocated_clients"
	
	post "search_results" => "clients#search_results"
	get "search_results" => "clients#search_results"

  resources :locations

	resources :location_tags
	
  resources :rooms

	root 'sessions#attempt_login'
  
  resources :obs

  resources :encounters

  resources :admins

  resources :schedules

  resources :htcs

  resources :clients

  resources :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
