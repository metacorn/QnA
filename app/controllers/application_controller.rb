class ApplicationController < ActionController::Base
  def non_owned?(content)
    content.user != current_user
  end
end
