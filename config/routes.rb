CatarsePayulatam::Engine.routes.draw do
  resources :payulatam, only: [], path: 'payment/payulatam' do
	  member do
	    get :review
	    get :respond
	    post :confirm
	  end
	end
end
