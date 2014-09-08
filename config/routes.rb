HTCModule::Application.routes.draw do
  get "reports/index"
	get "/login" => "sessions#attempt_login"
	post "/login" => "sessions#login", as: :log_in
	get "/logout" => "sessions#logout", as: :log_out

	get "search" => "clients#search"
	post "search" => "clients#search"

	get "client_demographics" => "clients#demographics"
	post "client_demographics" => "clients#demographics"
  
  get "referral_consent/:id" => "clients#referral_consent"

  get "appointment/:id" => "clients#appointment"
	#get "assign_client_to_unlocated_list" => "clients#assign_to_unlocated_list"
  get "clients/:id/add_to_unallocated" => "clients#add_to_unallocated", as: :add_to_unallocated
  get "htcs/swap_desk" => "htcs#swap_desk", as: :swap_desk
  post "htcs/swap" => "htcs#swap", as: :swap
  
  #get "clients/remove_from_waiting_list" => "clients#remove_from_waiting_list", as: :remove_from_waiting_list
  post "clients/remove_from_waiting_list" => "clients#remove_from_waiting_list", as: :remove_from_waiting_list
  
  get "clients/:id/assign_to_counseling_room" => "clients#assign_to_counseling_room", as: :assign_to_counseling_room

	post "encounters/new/:id" => "encounters#new", as: :new

  #post "assign_to_unlocated" => "clients#assign_to_unlocated"

  #get '/assign_to_unlocated_list/:id', to: 'clients#assign_to_unlocated_list'

	get "client_counseling" => "clients#counseling"
	post "client_counseling" => "clients#counseling"
	post "show_client" => "clients#show"

	get "protocols" => "admins#protocols"
	get "edit_protocols" => "admins#edit_protocols"
	post "edit_protocols" => "admins#edit_protocols"
	
	get "update_protocol_position/:id/:position" => "admins#update_protocol_position"
	
	get "new_protocol" => "admins#new_protocol"
	post "new_protocol" => "admins#new_protocol"

	get "client_testing" => "clients#testing"
	post "client_testing" => "clients#testing"

	get "client_previous_visit" => "clients#previous_visit"
	post "client_previous_visit" => "clients#previous_visit"

	get "client_current_visit" => "clients#current_visit"
	post "client_current_visit" => "clients#current_visit"

	get "encounters/observations/:id" => "encounters#observations"
	post "encounters/void/:id" => "encounters#void"

	get "clients/locations/:id" => "clients#locations"

	get "clients/village/:id" => "clients#village"

	get "clients/print_accession/:id" => "clients#print_accession"

  get "clients/print_summary/:id" => "clients#print_summary"

	get "clients/first_name/:id" => "clients#first_name"

	get "clients/last_name/:id" => "clients#last_name"
	
	get "waiting_list" => "clients#waiting_list"
	#post "unallocated_clients" => "clients#unallocated_clients"
	
	
	post "search_results" => "clients#search_results"
	get "search_results" => "clients#search_results"

	get "admins/set_date" => "admins#set_date" 
	post "admins/set_date" => "admins#set_date"
	
	get "htcs/dashboard" => "htcs#dashboard"

	get "locations/destroy/:id" => "locations#destroy"

	get "locations/print/:id" => "locations#print"
	post "/locations/new" => "locations#new"

	get "/locations/village" => "locations#village"

  get "client_printouts" => "clients#printouts"

   get "client_tasks" => "clients#tasks"

  get "/encounters/void/:id" => "encounters#void"

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


	post "/users/new" => "users#new"
	get "/users/destroy/:id" => "users#destroy"
	get "/users/retire/:id" => "users#retire"
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
