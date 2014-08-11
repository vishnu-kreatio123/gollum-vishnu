require_relative '../../lib/set_authorization'
Rails.application.config.middleware.insert_after(ActionDispatch::Flash, SetAuthorization)

USERNAME = {}