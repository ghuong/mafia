Rails.application.routes.draw do
  root 'static_pages#home'
  get '/help',          to: 'static_pages#help'

  # Rooms
  get '/rooms/new',          to: 'rooms#new', as: 'new_room'
  post '/rooms',             to: 'rooms#create'
  get '/rooms/:room_code',   to: 'rooms#show', as: 'room'
  post '/rooms/join',        to: 'rooms#show', as: 'join'

  # Users
  get '/rooms/:room_code/users/new', to: 'users#new', as: 'new_user'  
  post '/rooms/:room_code/users',    to: 'users#create', as: 'users'

  # Settings
  get '/rooms/:room_code/settings',  to: 'settings#edit', as: 'edit_settings'

  # Actions
  get '/rooms/:room_code/actions/edit', to: 'actions#edit', as: 'edit_actions'

  # Verdicts
  get '/rooms/:room_code/verdict',  to: 'verdicts#show', as: 'verdict'
end
