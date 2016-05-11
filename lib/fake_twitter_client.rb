module FakeTwitterClient

  def api
    # Credentials from fake twitter profile (feel_money)
    # Twitter_account @feel_money => password@123
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = "THafGffEG4azNrnHrljFaeoa4"
      config.consumer_secret = "SUqm76rtjtTihkVOT66OcoA0McxDm61Hs9mDjKIe4hA0wcnIRx"
      config.access_token = "723870595809595393-VCGcaLDVonTFrLmDVZu1sESWMFp6Uog"
      config.access_token_secret = "xEkqAoF6ux4wH2ERkFuF7J75Emz5CUBNUN0zBsR3mCz5w"
    end
  end

  module_function :api

end
