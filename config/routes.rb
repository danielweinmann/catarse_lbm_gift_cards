CatarseLbmGiftCards::Engine.routes.draw do
  resources :lbm_gift_cards, only: [], path: 'payment/lbm_gift_cards' do
	  member do
	    get :review
	    post :pay
	  end
	end
end
