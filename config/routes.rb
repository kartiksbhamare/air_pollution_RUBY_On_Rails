Rails.application.routes.draw do
  root 'home#first'
  get '/search', to: 'home#search'
  get '/index', to: redirect('/search?city=&commit=Search')
  get 'show', to: 'home#show', as: :show
  get 'generate_pdf', to: 'home#generate_pdf', as: 'home_generate_pdf'
end
