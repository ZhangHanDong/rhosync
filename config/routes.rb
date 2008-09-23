ActionController::Routing::Routes.draw do |map|

  # Sample of regular route:
  map.connect 'sources/:id/show', :controller => 'sources', :action => 'show'
  map.connect 'sources/:id/updateobjects', :controller => 'sources', :action => 'updateobjects'
  map.connect 'sources/:id/createobjects', :controller => 'sources', :action => 'createobjects'
  map.connect 'sources/:id/deleteobjects', :controller => 'sources', :action => 'deleteobjects'
  map.connect 'sources/:id/create', :controller => 'sources', :action => 'create'
  map.connect 'sources/:id/update', :controller => 'sources', :action => 'update'
  map.connect 'sources/:id/delete', :controller => 'sources', :action => 'delete'
  map.connect 'sources/:id/refresh', :controller => 'sources', :action => 'refresh'
  map.connect 'sources/:id/do_load_adapter',:controller=>'sources',:action => 'do_load_adapter'

  map.resources :object_values

  map.resources :sources

  map.resources :stores


  # The priority is based upon order of creation: first created -> highest priority.


  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "sources"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
