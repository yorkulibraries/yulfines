module FormatHelper
  def format_date(date, format: "%b %e, %Y")
    if date == nil
      content_tag(:span, "No date...", class: "tiny trivial")
    else
      date.strftime(format)
    end
  end

end
