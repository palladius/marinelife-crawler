Rails.application.routes.draw do
  resources :wiki_animals
  root to: 'welcome#index'
  get 'welcome/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
