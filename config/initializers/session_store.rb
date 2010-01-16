# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_rails-3-blog_session',
  :secret => '4e77baec65ee852091d10e04c329be6c3b4fd3727c10496bd45de242954ebefd34173b778360b06ae809c99ca91b88c295b99b687268bde652a0379f9f37a99a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
