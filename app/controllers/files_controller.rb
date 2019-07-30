class FilesController < ApplicationController
  authorize_resource

  def destroy
    @file = ActiveStorage::Attachment.find(params[:id])
    return head :forbidden unless @file.record_type.in?(%w[Question Answer])
    @file.purge if current_user&.owner?(@file.record)
  end
end
