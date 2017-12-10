Rails.application.routes.draw do
  root 'static_pages#home'
  get '/help',          to: 'static_pages#help'

  # Rooms
  get '/rooms/new',          to: 'rooms#new', as: 'new_room'
  post '/rooms',             to: 'rooms#create'
  get '/rooms/:room_code',   to: 'rooms#show', as: 'room'

  # Users
  get '/rooms/:room_code/users/new', to: 'user#new', as: 'new_user'  
  post '/rooms/:room_code/users',    to: 'user#create'
end
