module ApplicationHelper

  def pp(object)
    begin
      (ap object).html_safe
    rescue
    end
  end
end
