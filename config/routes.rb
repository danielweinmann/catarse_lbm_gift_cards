CatarsePayroll::Engine.routes.draw do
  resources :payroll, only: [], path: 'payment/payroll' do
	  member do
	    get :review
	    match :respond
	    match :confirm
	  end
	end
end
