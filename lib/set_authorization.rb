require 'gollum/app'
require 'digest/sha1'

class SetAuthorization
  def initialize(app)
    @app= app
  end

  def call(env)
    status, headers, body = @app.call(env)
  end
end

module Precious
  App.class_eval do
    User = Struct.new(:name, :email, :password_hash, :message)

    before /edit|create|rename/ do
      authenticate!
    end

    helpers do
      def authenticate!
        @_auth ||=  Rack::Auth::Basic::Request.new(request.env)
        if @_auth.provided?
        end
        if @_auth.provided? && @_auth.basic? && @_auth.credentials &&
            @user = detected_user(@_auth.credentials)
            USERNAME[:username] = @_auth.credentials[0]
          return @user
        else
          response['WWW-Authenticate'] = %(Basic realm="Gollum Wiki")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def users
        @_users ||= settings.authorized_users.map {|u| User.new(*u) }
      end

      def detected_user(credentials)
        users.detect do |u|
          [u.email, u.password_hash] ==
              [credentials[0], Digest::SHA1.hexdigest(credentials[1])]
        end
      end
    end

    def commit_message
      {
          :message => params[:message],
          :name => @user.name,
          :email => @user.email
      }
    end
  end
end