module ReportsHelper

  def library_list
    [["All", "all"], ["York University Libraries", "yorku"], ["Osgoode Law Library", Alma::Fee::OWNER_OSGOODE]]
  end

  def library_name(id)
    if id == Alma::Fee::OWNER_OSGOODE
      "Osgoode Law Library"
    else
      "York University Libraries"
    end
  end
end
