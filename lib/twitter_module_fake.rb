module TwitterModuleFake

  def client
    if Rails.env.production?
      # Credentials from fake twitter profile (feel_money)
      # Twitter_account @feel_money => password@123
      @twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = "THafGffEG4azNrnHrljFaeoa4"
        config.consumer_secret = "SUqm76rtjtTihkVOT66OcoA0McxDm61Hs9mDjKIe4hA0wcnIRx"
        config.access_token = "723870595809595393-VCGcaLDVonTFrLmDVZu1sESWMFp6Uog"
        config.access_token_secret = "xEkqAoF6ux4wH2ERkFuF7J75Emz5CUBNUN0zBsR3mCz5w"
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
