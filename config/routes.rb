Rails.application.routes.draw do
  get 'about/me'
  root :to => 'pages#home' # Replace this with whatever you want your root_path to be.
  get '/login' => 'session#new' # This will be our sign-in page.
  post '/login' => 'session#create' # This will be the path to which the sign-in form is posted
  delete '/login' => 'session#destroy' # This will be the path users use to log-out.
end