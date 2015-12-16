class Image
	attr_reader :url

	def initialize
		@url = getImageUrl
	end

	private

  def getImageUrl
    # Config yahoo api.
    YBoss::Config.instance.oauth_key = ENV['YBOSS_KEY']
    YBoss::Config.instance.oauth_secret = ENV['YBOSS_SECRET']
    rand = Random.new

    # Grab a random noun from list and query image search with it.
    noun = IO.readlines("#{Rails.root}/lib/seeds/nounlist.txt")[rand(1..2327)]
    res = YBoss.images('q' => noun, 'format' => 'json', 'count' => '1', 'start' => rand(1..300).to_s, 'dimensions' => 'medium')

    # Make sure image doesn't return error code and is either a jpg or png.
    # Will make another API call if all 35 results are bad. (Let's hope not!)
    stillLooking = true
    count = 0

    while stillLooking
      if count >= 34
        res = YBoss.images('q' => noun, 'format' => 'json', 'count' => '1', 'start' => rand(1..300).to_s, 'dimensions' => 'medium')
        count = 0
      end

      imgRes = HTTParty.get(res.items[count].url)

      if imgRes.response.is_a?(Net::HTTPOK)
        stillLooking = false
      else
        stillLooking = true
      end
    end

    # Return successful image url
    @imageUrl = res.items[count].url
  end
end
