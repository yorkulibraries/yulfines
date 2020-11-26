module LayoutHelper
  def page_title(title="Untitled")
    content_for(:page_title) { h title.to_s }
  end

  def page_header(header, page_title: false)
    content_for(:page_header) { h header.to_s }
    page_title header if page_title == true

  end

  def page_description(description)
      content_for(:page_description) { h description.to_s }
  end

end
