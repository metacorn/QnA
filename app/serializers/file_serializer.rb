class FileSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :filename, :url, :created_at

  def id
    object.id
  end

  def filename
    object.blob.filename
  end

  def url
    rails_blob_path(object, only_path: true)
  end
end
