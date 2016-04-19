class TwitterDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view, followers)
    @view = view
    @followers = followers
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
        f.name,
        get_is_friend(f.is_friend),
        get_is_following(f.is_following),
        get_twitter_link(f.screen_name),
        f.twitter_id,
        f.is_processed
      ]
    end
  end

  def results
    @results ||= fetch_followers
  end

  def fetch_followers
    followers = @followers.order("created_at DESC").order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    if params[:sSearch].present? 
      followers = followers.where("name like :search or screen_name like :search", search: "%#{params[:sSearch]}%")
    end
    followers
  end

  def sort_column
    columns = %w[name is_friend is_following "" "" ""]
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

  def get_twitter_link screen_name
    "<a href='https://twitter.com/"+screen_name+"' target='_blank'><img src='/assets/twitter.png' width='20'/></a>".html_safe
  end

  def get_is_friend bool_friend
    if bool_friend
      return "<span>Friend</span>".html_safe
    else
      return "<span>Not Friend</span>".html_safe
    end
  end

  def get_is_following bool_follow
    if bool_follow
      return "<span>Following</span>".html_safe
    else
      return "<span>Not Following</span>".html_safe
    end
  end

end