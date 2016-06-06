class ConciergeDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view, concierge)
    @view = view
    @concierge = concierge
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: results.count,
      iTotalDisplayRecords: results.count,
      aaData: data
    }
  end

  private

  def data
    results.map do |f|
      [
        f.id,
        f.name.to_s.titleize,
        f.email.to_s,
        f.company.to_s,
        get_description(f.description.to_s),
        f.created_at.strftime('%b %d %Y')
      ]
    end
  end

  def results
    @results ||= fetch_concierge
  end

  def fetch_concierge 
    concierges = @concierge.order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    if params[:sSearch].present? 
      concierges = concierges.where("name like :search or email like :search or company like :search", search: "%#{params[:sSearch]}%")
    end
    concierges
  end

  def sort_column
    columns = %w[id name email company "" created_at ]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def get_description description
    if description.length > 60
      desc = "
        <div class=\"text-justify\">#{description.truncate(60)}<a href=\"javascript:void(0);\" onclick=\"$(this).parent().toggle().next().toggle();\">Read more</a></div>
        <div class=\"text-justify\" style=\"display:none;\">#{description}<a href=\"javascript:void(0);\" onclick=\"$(this).parent().toggle().prev().toggle();\">Read less</a></div>
      "
    else
      desc = "
        <div class=\"text-justify\">#{description}</div>
      "
    end
    desc.html_safe
  end

end
