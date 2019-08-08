class QuestionDetailedSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :created_at, :updated_at
  has_many :links
  has_many :files, serializer: FileSerializer

  belongs_to :user

  has_many :comments

  def links
    object.links.order(:created_at)
  end
end
