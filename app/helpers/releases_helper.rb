module ReleasesHelper
  
  def releases_query releases, page = 1, per_page = 16, all = true
    page = page.to_i
    per_page = per_page.to_i

    if all
      @limit = page * per_page
      @offset = 0
    else
      @limit = per_page
      @offset = (page - 1) * per_page
    end

    @releases = releases.limit(@limit).offset(@offset)
  end
end


