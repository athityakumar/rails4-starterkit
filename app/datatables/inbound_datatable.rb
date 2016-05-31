class InboundDatatable
  delegate :params, :h, :link_to, to: :@view

  def initialize(view, inbound_users)
    @view = view
    @inbound_users = inbound_users
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
        get_user_name(f.name, f.id),
        get_following(f.following),
        get_followers(f.follower),
        f.date_processed.blank? ? "Not Yet" : f.date_processed,
        get_social_links(f.inbound_link,f.twitter_link,f.facebook_link,f.linkedin_link,f.googleplus_link)
      ]
    end
  end

  def results
    @results ||= fetch_inbound_users
  end

  def fetch_inbound_users 
    inbound_users = @inbound_users.order("#{sort_column} #{sort_direction}").page(page).per_page(per_page) 
    if params[:sSearch].present?
      search_select = params[:sSearch].split(":select:")[1]
      params[:sSearch] = params[:sSearch].gsub(":select:","").gsub(search_select,"")    
      if search_select.to_i > 4
        lower , upper = params[:sSearch].split("-") 
      end
      if search_select == "1"
        inbound_users = inbound_users.where("name like :search or replace(inbound_link, 'https://inbound.org/in/', '') like :search", search: "%#{params[:sSearch]}%")       
      elsif search_select == "2"
        inbound_users = inbound_users.where("company like :search or designation like :search", search: "%#{params[:sSearch]}%")         
      elsif search_select == "3"
        inbound_users = inbound_users.where("location like :search", search: "%#{params[:sSearch]}%")             
      elsif search_select == "4"
        inbound_users = inbound_users.where("badges like :search", search: "%#{params[:sSearch]}%") 
      elsif search_select == "5"
        inbound_users = inbound_users.where("karma < ? and karma > ?", upper , lower)         
      elsif search_select == "6"
        inbound_users = inbound_users.where("number_followers < ? and number_followers > ?", upper , lower)         
      elsif search_select == "7"
        inbound_users = inbound_users.where("number_following < ? and number_following > ?", upper , lower)         
      elsif search_select == "8"
        inbound_users = inbound_users.where("number_badges < ? and number_badges > ?", upper , lower)         
      end
    end 
    inbound_users
  end

  def sort_column
    columns = %w[name following follower date_processed "" ]
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

  def get_social_links inbound , twitter , facebook , linkedin , googleplus
    social_links = "<a href='"+inbound+"' target='_blank'><img src='/assets/inbound.png' width='25'/></a>&nbsp;<a href='"+twitter+"' target='_blank'><img src='/assets/twitter.png' width='25'/></a>"
    if !facebook.blank? 
      social_links = social_links + "&nbsp;<a href='"+facebook+"' target='_blank'><img src='/assets/facebook.png' width='25'/></a>"
    end  
    if !linkedin.blank? 
      social_links = social_links + "&nbsp;<a href='"+linkedin+"' target='_blank'><img src='/assets/linkedin.png' width='25'/></a>"
    end  
    if !googleplus.blank? 
      social_links = social_links + "&nbsp;<a href='"+googleplus+"' target='_blank'><img src='/assets/googleplus.png' width='25'/></a>"
    end  
    social_links.html_safe
  end

  def get_user_name name, user_id
    "<a href=\"javascript:void(0);\" class=\"inbound-user-modal\" data-user-id="+user_id.to_s+">"+name+"</a>".html_safe
  end

  def get_following bool_following
    if bool_following
      return "<img style='margin-left: 20px;' src='/assets/yes.png' width='20'/>".html_safe
    else
      return "<img style='margin-left: 20px;' src='/assets/no.png' width='20'/>".html_safe
    end
  end

  def get_followers bool_follower
    if bool_follower
      return "<img style='margin-left: 20px;' src='/assets/yes.png' width='20'/>".html_safe
    else
      return "<img style='margin-left: 20px;' src='/assets/no.png' width='20'/>".html_safe
    end
  end

end