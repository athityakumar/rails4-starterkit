module PipecandyTwitterClient

  def api
    if Rails.env.production?
      # Credentials from PipecandyHQ twitter profile
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = "42xShxgXfxcmCafn92vnBWeOQ"
        config.consumer_secret = "1xuI5cgtl09PRX3t6mdOH8YLlrc8rchr0XwsMK0KK4fgMIof5L"
        config.access_token = "4812127693-aMMjNTgPYulpN19KGp4Hqq3hp4LJtTNiL2nw1Up"
        config.access_token_secret = "kqOjj49JVP5YhICMKS4xvVg2ocefpGMHf7B4Z4MVzfDmO"
      end
    else 
      # Credentials from fake twitter profile (feel_money)
      # Twitter_account @feel_money => password@123
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = "THafGffEG4azNrnHrljFaeoa4"
        config.consumer_secret = "SUqm76rtjtTihkVOT66OcoA0McxDm61Hs9mDjKIe4hA0wcnIRx"
        config.access_token = "723870595809595393-VCGcaLDVonTFrLmDVZu1sESWMFp6Uog"
        config.access_token_secret = "xEkqAoF6ux4wH2ERkFuF7J75Emz5CUBNUN0zBsR3mCz5w"
      end
    end
  end

  module_function :api

end
