class TwitterTweetsDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view, tweets)
    @view = view
    @tweets = tweets
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
        f.created_at,
        f.tweet
      ]
    end
  end

  def results
    @results ||= fetch_tweets
  end

  def fetch_tweets
    tweets = @tweets.order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
    if params[:sSearch].present? 
      tweets = tweets.where("tweet like :search", search: "%#{params[:sSearch]}%")
    end
    tweets
  end

  def sort_column
    columns = %w[created_at tweet]
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

end