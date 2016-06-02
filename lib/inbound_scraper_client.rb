require 'mechanize'
require 'logger'
require 'resolv-replace'

module InboundScraperClient

  def api
    begin
      @agent = Mechanize.new do |a|
        a.log = Logger.new "log/inbound_scraper.log"
        a.history_added = Proc.new { sleep 5 }
        a.follow_meta_refresh = true
        # Mechanize::AGENT_ALIASES shows list of user agents
        a.user_agent_alias = "Mac Safari 4"
        a.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      # Check the Cookie
      # cookie = "log/inbound_cookie.yml"
      # if File.exist?(cookie)
      #   @agent.cookie_jar.load(cookie)
      #   cookieJar = @agent.cookie_jar.jar
      #   unless cookieJar.empty?
      #     inboundSession = ["inbound.org", "/", "inbound6session"].reduce(cookieJar) {|v, k| v && v[k]}
      #     unless inboundSession.blank?
      #       unless inboundSession.expired? then return @agent end
      #     end
      #   end
      # end
      if Rails.env.production?
        ajax_login = @agent.post("https://inbound.org/authenticate/check", {
          email: "ashwin@pipecandy.com",
          password: "ashwin0302"
        })
      else
        ajax_login = @agent.post("https://inbound.org/authenticate/check", {
          email: "danyjontyrion@gmail.com",
          password: "dragonblood"
        })
      end
      # Auth Success
      parse_response = JSON.parse(ajax_login.body)
      if parse_response["success"]
        # @agent.cookie_jar.save_as(cookie)
        return @agent
      else
        raise parse_response["message"].to_s
      end
    rescue Exception => e
      puts "===================InboundScraperClient Error===================="
      puts "Error Message: #{e.to_s}"
      puts "================================================================="
    end
  end

  module_function :api

end
