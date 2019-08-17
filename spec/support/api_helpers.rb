module ApiHelpers
  def json
    @json ||= JSON.parse(response.body)
  end

  def do_request(meth, path, options)
    send meth, path, options
  end
end
