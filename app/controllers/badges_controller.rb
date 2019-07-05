class BadgesController < ApplicationController
  before_action :authenticate_user!, only: %i[index]

  def index
    @badges = current_user.badges
  end
end
