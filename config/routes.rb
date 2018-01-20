Rails.application.routes.draw do
  root 'static_pages#home'
  get '/help',          to: 'static_pages#help'

  # Rooms
  get '/rooms/new',          to: 'rooms#new', as: 'new_room'
  post '/rooms',             to: 'rooms#create'
  get '/rooms/:room_code',   to: 'rooms#show', as: 'room'
  post '/rooms/join',        to: 'rooms#join', as: 'join'

  # Users
  get '/rooms/:room_code/users/new', to: 'users#new', as: 'new_user'  
  post '/rooms/:room_code/users',    to: 'users#create', as: 'users'
  delete '/rooms/:room_code/users',  to: 'users#destroy'

  # Settings
  get '/rooms/:room_code/settings',                             to: 'settings#edit', as: 'edit_settings'
  post '/rooms/:room_code/settings/increment_role/:role_id',    to: 'settings#increment_role', as: 'increment_role'
  post '/rooms/:room_code/settings/add_role',                   to: 'settings#add_role', as: 'add_role'
  post '/rooms/:room_code/settings/remove_role/:role_id',       to: 'settings#remove_role', as: 'remove_role'
  post '/rooms/:room_code/settings/start_game',                 to: 'settings#start_game', as: 'start_game'

  # Actions
  get '/rooms/:room_code/actions/edit',     to: 'actions#edit', as: 'edit_actions'
  post '/rooms/:room_code/actions',         to: 'actions#update', as: 'actions'
  get '/rooms/:room_code/death',            to: 'actions#death', as: 'death'
  post '/rooms/:room_code/action',          to: 'actions#update_single', as: 'single_action'

  # Publish messages with private_pub
  post '/publish/:room_code/announce_user_joining',         to: 'publish#announce_user_joining'
  post '/publish/:room_code/announce_user_leaving',         to: 'publish#announce_user_leaving'
  post '/publish/:room_code/announce_roles_updated',        to: 'publish#announce_roles_updated'
  post '/publish/:room_code/announce_game_started',         to: 'publish#announce_game_started'
  post '/publish/:room_code/announce_day_phase_changed',    to: 'publish#announce_day_phase_changed'
  post '/publish/:room_code/announce_user_kicked/:user_id', to: 'publish#announce_user_kicked'
  post '/publish/:room_code/announce_vote_changed/:action_id/:action_name/:user_id', to: 'publish#announce_vote_changed'
end
