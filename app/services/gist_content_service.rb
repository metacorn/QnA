class GistContentService
  def initialize(gist_id, client: default_client)
    @gist_id = gist_id
    @client = client
  end

  def content
    begin
      response = @client.gist(@gist_id)
      files_array = []
      response[:files].each { |k, v| files_array << v.to_h.slice(:filename, :content) }
      files_array
    rescue Octokit::NotFound
      nil
    end
  end

  private

  def default_client
    Octokit::Client.new
  end
end
