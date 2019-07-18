module AnswersHelper
  def files_list(files)
    files.map do |file|
      { name: file.filename.to_s,
        url: url_for(file) }
    end
  end

  def links_list(links)
    links.map.with_index do |link, index|
      { id: link.id,
        number: index + 1,
        name: link.name,
        url: link.url,
        gist_content: link.gist? ? link.gist_content : '' }
    end
  end
end
