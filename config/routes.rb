CatarsePayulatam::Engine.routes.draw do
  namespace :payment do
    get '/payulatam/:id/review' => 'payulatam#review', :as => 'review_payulatam'
    post '/payulatam/notifications' => 'payulatam#ipn',  :as => 'ipn_payulatam'
    match '/payulatam/:id/notifications' => 'payulatam#notifications',  :as => 'notifications_payulatam'
    match '/payulatam/:id/success'       => 'payulatam#success',        :as => 'success_payulatam'
    match '/payulatam/:id/cancel'        => 'payulatam#cancel',         :as => 'cancel_payulatam'
  end
end
