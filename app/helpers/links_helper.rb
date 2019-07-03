module LinksHelper
  def deleting_link(link)
    link_to('Delete link', link_path(link), method: :delete, remote: true)
  end
end
