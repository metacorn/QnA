class LinksController < ApplicationController
  before_action :authenticate_user!, only: %i[destroy]

  authorize_resource

  def destroy
    @link = Link.find(params[:id])
    return head :forbidden unless current_user.owner?(@link.linkable)
    @link.destroy
    @links = @link.linkable.links
  end
end
