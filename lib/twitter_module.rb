module TwitterModule

  def client
    if Rails.env.production?
      # Credentials from PipecandyHQ twitter profile
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = "42xShxgXfxcmCafn92vnBWeOQ"
        config.consumer_secret = "1xuI5cgtl09PRX3t6mdOH8YLlrc8rchr0XwsMK0KK4fgMIof5L"
        config.access_token = "4812127693-aMMjNTgPYulpN19KGp4Hqq3hp4LJtTNiL2nw1Up"
        config.access_token_secret = "kqOjj49JVP5YhICMKS4xvVg2ocefpGMHf7B4Z4MVzfDmO"
      end
    else 
      # Credentials from thangadurai twitter profile
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = "bKkUkkna5eVuGo7XYVF3j2g0x"
        config.consumer_secret = "VAXJm2fxhPFyxSP0EAs7Uv8tfrqpYzARg9wXowMedKSw4r8ElH"
        config.access_token = "340263856-1FfyCE1UR0uC9WGAETo1nYFK6r9NJDcPtuBCuVxK"
        config.access_token_secret = "yWK6IhJKkBR22X2IBW9Rv1gsRtgqIGvcFdr5c2SoSnk4J"
      end
    end
  end

  module_function :client

end
