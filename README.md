# README

=== Preparation ===

* Ruby version:
ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-darwin16]

--- Setup ---

Run:
  `bundle install`
  `bundle update`

Migrate database:
  `rails db:migrate`
  `rails db:migrate RAILS_ENV=test`

Run the private_pub generator:
  `rails generate private_pub:install`

--- Test ---

Verify all tests pass:
  `rails test`

--- Run ---

Start Rack server:
  `rackup private_pub.ru -s thin -E production`

Start Rails server (in separate terminal):
  `rails server`

Visit 'localhost:3000/' to visit homepage

=== What is this? ===

This is a web app that allows a group of friends who are hanging out in the same real-life room to play a game of Mafia without a host. The only requirement is that each person has a phone with an internet connection, and can access this web app through a browser. No sign-up is required.

=== Architecture ===

-- Controllers --

StaticPagesController:
- Handles requests for simple static pages (home and help pages)

RoomsController:
- Handles requests to create new rooms, or to join existing rooms
- Upon creating or joining a room, one is authenticated with a throwaway User model (without sign-up), tied to the Room; the room creator is the "host"
- Rooms begin in 'pre-game' state
- Non-hosts join rooms with a 4-letter code

UsersController:
- Handles requests to create a throwaway User account, no password required

SettingsController:
- While game is in 'pre-game' state, the host can tweak various game settings

ActionsController:
- Handles all game-related requests

-- Models --

Room:
- Represents a single play session of Mafia
- Begins in pre-game state
- Has a random unique 4-letter "code", which is required in the URL to access the room

User:
- Represents a player in a Room
- Not having to sign-up is intentional: it is not necessary for this application