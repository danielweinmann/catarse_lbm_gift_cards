CatarsePayroll::Engine.routes.draw do
  resources :payroll, only: [], path: 'payment/payroll' do
	  member do
	    get :review
	    post :pay
	  end
	end
end
