class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true

  validates :name, :url, presence: true
  validate :validate_url_format

  def gist?
    gist_content ? true : false
  end

  def gist_id
    if matchings = url.match(/https:\/\/gist.github.com\/\w+\/(\w+)/)
      matchings[1]
    end
  end

  def gist_content
    @gist_content ||= GistContentService.new(gist_id).content
  end

  private

  def validate_url_format
    unless url && URI.parse(url).kind_of?(URI::HTTP)
      errors.add(:format, 'is an invalid URL')
    end
  end
end
