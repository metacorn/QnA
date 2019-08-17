class Api::V1::ProfilesController < Api::V1::BaseController
  authorize_resource class: User

  def me
    render json: current_user, serializer: UserSerializer
  end

  def index
    render json: User.where.not(id: current_user.id), each_serializer: UserSerializer
  end
end
