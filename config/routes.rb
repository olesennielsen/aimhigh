Aimhigh::Application.routes.draw do

  root :to => 'home#index'
	
  # Devise for admins and athletes but no registration possible
  # without an invitation
  
  devise_for :admins, :skip => :registrations 
  devise_scope :admin do
    get 'admins/edit' => 'devise/registrations#edit', :as => 'edit_admins_registration'
    put 'admins' => 'devise/registrations#update', :as => 'admin_registration'
  end
  
  devise_for :athletes, :skip => :registrations 
  devise_scope :athlete do 
    get 'athletes/edit' => 'devise/registrations#edit', :as => 'edit_athletes_registration'
    put 'athletes' => 'devise/registrations#update', :as => 'athlete_registration'
  end
  # Common ressource url for both athletes and admins
  # events are nested for athletes (note: athlete --hasmany--> events)
  
  resources :athletes do 
    resources :events, :only => [:index, :show] 
    resources :attachments, :only => [:create, :index, :new, :destroy]
    resources :documents
    get 'listdocs' => 'documents#listdocs'
    put 'changestatus' => 'athletes#changestatus'
    post 'exportcal' => 'athletes#exportcal'      	
    post 'exportpdf' => 'athletes#exportpdf'
    get 'showlink' => 'athletes#showlink'      	
  end 
  resources :admins
	
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
