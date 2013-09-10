CatarsePayulatam::Engine.routes.draw do
  resources :payulatam, only: [], path: 'payment/payulatam' do
	  member do
	    get :review
	    match :respond
	    match :confirm
	  end
	end
end
