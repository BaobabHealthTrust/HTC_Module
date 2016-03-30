HTCModule::Application.routes.draw do
  get "clients/new"
  get "counselor/test_details"
  get "list_tests" => "counselor#list_tests"
  get  "counselor/monthly_details"
  get  "counselor/moh_details"
  get "add_test" => "counselor#new_test"
  get "sample" => "counselor#sample"
  get "counselor/final_result"
  get "couple/status"
  get "couple/testing"
  get "couple/counseling"
  get "couple/assessment"
  get "monthly" => "reports#monthly_report"
  get "moh_report" => "reports#moh_report"

  get "clients/choose_sample"
  post "clients/choose_sample"

  get "mohquartery_report" => "reports#mohquartery_report"

  get "couple/appointment"
  get "reports/index"
  get "reports/stock_report"
  get "reports/temp_changes"
  get "reports/ajax_temp_changes"
  get "reports/ajax_stock_levels_report"
	get "/login" => "sessions#attempt_login"
	post "/login" => "sessions#login", as: :log_in
	get "/logout" => "sessions#logout", as: :log_out
  get "people/districts_for"
  get "people/traditional_authority"
  get "people/village"
  get "people/landmark"
	get "search" => "dde#search"
	post "search" => "dde#search"

  get "ajax_search" => "dde#ajax_search"
  post "ajax_search" => "dde#ajax_search"
  post "process_result" => "dde#process_result"

  post "dde/send_to_dde"
  post "dde/ajax_process_data"
  post "dde/process_confirmation"
  post "dde/process_scan_data"

  post "dde/process_result"
  get  "dde/process_result"

  get  "dde/process_data"
  get "patient_not_found/:id" => "dde#patient_not_found"
  post "patient_not_found/:id" => "dde#patient_not_found"

  get 'new_patient' => 'dde#new_patient'
	get "client_demographics" => "dde#edit_patient"
	post "client_demographics" => "dde#edit_patient"

  get "dde/edit_demographics"
  get "dde/edit_patient"

  get "clients/demographics_edit/:id" => "clients#demographics_edit"

  post "clients/modify_field/:id" => "clients#modify_field"
  
  get "referral_consent/:id" => "clients#referral_consent"

  get "inventory/batch_available" => "inventory#batch_available"

  get "extended_testing/:id" => "clients#extended_testing"

  get "appointment/:id" => "clients#appointment"
  get "clients/appointment" => "clients#appointment"
	#get "assign_client_to_unlocated_list" => "clients#assign_to_unlocated_list"
  get "clients/:id/add_to_unallocated" => "clients#add_to_unallocated", as: :add_to_unallocated
  get "htcs/swap_desk" => "htcs#swap_desk", as: :swap_desk
  post "htcs/swap" => "htcs#swap", as: :swap

  get "htcs/record_temp" => "inventory#record_temp", as: :record_temp
  post "htcs/record_temp" => "inventory#record_temp"
  
  #get "clients/remove_from_waiting_list" => "clients#remove_from_waiting_list", as: :remove_from_waiting_list
  post "clients/remove_from_waiting_list" => "clients#remove_from_waiting_list", as: :remove_from_waiting_list
  
  get "clients/:id/assign_to_counseling_room" => "clients#assign_to_counseling_room", as: :assign_to_counseling_room

	post "encounters/new/:id" => "encounters#new", as: :new

  #post "assign_to_unlocated" => "clients#assign_to_unlocated"

  #get '/assign_to_unlocated_list/:id', to: 'clients#assign_to_unlocated_list'
  get "client_assessment/:id" => "clients#assessment"

  get "client_risk_assessment" => "clients#risk_assessment"
  
  get "search_couple/:id" => "clients#search_couple"

  post "search_couple/:id" => "clients#search_couple"

  get "client_status/:id" => "clients#status"
	get "client_counseling" => "clients#counseling"
	post "client_counseling" => "clients#counseling"

  get "early_infant_diagnosis/:id" => "clients#early_infant_diagnosis"
  post "early_infant_diagnosis" => "clients#early_infant_diagnosis"
  get "early_infant_diagnosis_menu/:id" => "clients#early_infant_diagnosis_menu"
  post "early_infant_diagnosis_menu/" => "clients#early_infant_diagnosis_menu"
  get "early_infant_diagnosis_results/:id" => "clients#early_infant_diagnosis_results"
  post "early_infant_diagnosis_results/" => "clients#early_infant_diagnosis_results"

  get "eid_care_giver/:id" => "clients#eid_care_giver"
  post "eid_care_giver/" => "clients#eid_care_giver"

  get "find_register_caregiver/:id" => "clients#find_register_caregiver"
  post "find_register_caregiver/" => "clients#find_register_caregiver"

  get "care_giver_search_results/" => "clients#care_giver_search_results"
  post "care_giver_search_results/" => "clients#care_giver_search_results"

  get "hiv_viral_load/:id" => "clients#hiv_viral_load"
  get "hiv_viral_load_menu/:id" => "clients#hiv_viral_load_menu"
  post "hiv_viral_load_menu/" => "clients#hiv_viral_load_menu"
  post "hiv_viral_load" => "clients#hiv_viral_load"
  get "hiv_viral_load_results/:id" => "clients#hiv_viral_load_results"
  post "hiv_viral_load_results/" => "clients#hiv_viral_load_results"

  get "create_care_giver/" => "clients#create_care_giver"
  post "create_care_giver/" => "clients#create_care_giver"

  post "scan_caregiver/" => "clients#scan_caregiver"

  get "select_caregiver/" => "clients#select_caregiver"

	post "show_client" => "clients#show"

  get "dde/update_demographics"

	get "protocols" => "admins#protocols"
  get "tests" => "admins#tests"
  get "new_test" => "admins#new_test"
	get "edit_protocols" => "admins#edit_protocols"
	post "edit_protocols" => "admins#edit_protocols"
	
	get "update_protocol_position/:id/:position" => "admins#update_protocol_position"
	
	get "new_protocol" => "admins#new_protocol"
	post "new_protocol" => "admins#new_protocol"

  get "stock_levels" => "inventory#stock_levels"
  get "kit_loss" => "inventory#kit_loss"
  post "kit_loss" => "inventory#kit_loss"

  get "inventory" => "inventory#options"
  get "new_batch" => "inventory#new_batch"

  get "ajax_stock_levels" => "inventory#ajax_stock_levels"

  get "physical_count" => "inventory#physical_count"
  post "physical_count" => "inventory#physical_count"

  post "create_batch" => "inventory#create"
  get "edit_batch" => "inventory#edit"

  get "distribute_batch" => "inventory#distribute"
  post "distribute_batch" => "inventory#distribute"

  get "quality_control_tests" => "inventory#quality_control_tests"
  post "quality_control_tests" => "inventory#quality_control_tests"

  post "losses" => "inventory#losses"

  get "inventory/validate_dist" => "inventory#validate_dist"
  get "inventory/get_exp_date" => "inventory#get_exp_date"
  get "inventory/check_presence" => "inventory#check_presence"

	get "client_testing" => "clients#testing"
	post "client_testing" => "clients#testing"

	get "client_previous_visit" => "clients#previous_visit"
	post "client_previous_visit" => "clients#previous_visit"

	get "client_current_visit" => "clients#current_visit"
	post "client_current_visit" => "clients#current_visit"

	get "encounters/observations/:id" => "encounters#observations"
	post "encounters/void/:id" => "encounters#void"

	get "clients/locations/:id" => "clients#locations"

  get "clients/confirm/:id" => "clients#confirm"

  post "clients/confirm/:id" => "clients#confirm"

	get "clients/village/:id" => "clients#village"

	get "clients/print_accession/:id" => "clients#print_accession"

  get "clients/print_summary/:id" => "clients#print_summary"

  get "clients/print_confirmation/:id" => "clients#print_confirmation"

	get "clients/first_name/:id" => "clients#first_name"

  get "clients/first_name" => "clients#first_name"

	get "clients/last_name/:id" => "clients#last_name"

  get "clients/last_name" => "clients#last_name"
	
	get "total_bookings" => "clients#total_bookings"
	
	get "waiting_list" => "clients#waiting_list"

  post "new_client" =>  "clients#new"

  get "new_client" => "clients#new"

	#post "unallocated_clients" => "clients#unallocated_clients"


  post "search_new" => "clients#search_new"
  get "search_new" => "clients#search_new"

	post "search_results" => "clients#search_results"
	get "search_results" => "clients#search_results"

	get "admins/set_date" => "admins#set_date" 
	post "admins/set_date" => "admins#set_date"
	
	get "htcs/dashboard" => "htcs#dashboard"
  get "people" => "htcs#index"
  get "htcs/account" => "users#my_account"

	get "locations/destroy/:id" => "locations#destroy"

	get "locations/print/:id" => "locations#print"
	post "/locations/new" => "locations#new"

	get "/locations/village" => "locations#village"

  get "/locations/ta" => "locations#ta"

  get "client_printouts" => "clients#printouts"

  get "client_tasks" => "clients#tasks"

  ######################### new routes ################################
  get "people/new"
  post "new" => "people#new"

  get "people/region" #region_of_origin
  get "people/districts"
  get "people/ta"
  get "people/village"
  get "people/static_nationalities"
  get "people/static_countries"
  ######################### new routes end ################################


  get "/encounters/void/:id" => "encounters#void"

  resources :locations

	resources :location_tags
	
  resources :rooms

  get "sessions/server_date" => "sessions#server_date"

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
