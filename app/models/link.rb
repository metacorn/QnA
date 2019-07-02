class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true

  validates :name, :url, presence: true
  validate :validate_url_format

  private

  def validate_url_format
    unless url && URI.parse(url).kind_of?(URI::HTTP)
      errors.add(:format,'is an invalid URL')
    end
  end
end
