module Qedit
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session

    before_action :require_development!

    private

    def require_development!
      unless Rails.env.development?
        render plain: "403 Forbidden — qedit is only available in the development environment.", status: :forbidden
      end
    end
  end
end
