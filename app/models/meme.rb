class Meme
  attr_reader :imageUrl, :quote, :celebrity

  def initialize
    @imageUrl = getImageUrl
    @quote = getQuote
    @celebrity = getSanitizedCelebrity
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

  def getQuote
    result = false
    quotes = []

    # Loop until returned page has a 'quotes' section.
    while result == false
      res = HTTParty.get('https://en.wikiquote.org/w/api.php?format=json&action=parse&page=' + getCelebrity)
      data = res['parse']['text']['*']
      xpathData = Nokogiri::HTML data
      if xpathData.css("span[id='Quotes']").text == 'Quotes'
        result = true
      else
        result = false
      end

      # Parse quotes
      rawQuotes = xpathData.xpath("//ul/li").map{|data_node| data_node.text}
      rawQuotes.each do |quote|
        if match = quote.match(/(.+?)\n\n/)
          rawQuote = $1
          strippedQuote = rawQuote.gsub(/\"/, "'")
          quotes << strippedQuote
        end
      end

			# Verify quotes is not empty
      if quotes.length < 1
        result = false
      else
        result = true
      end

      selected = quotes[rand(0..(quotes.length))]

      if selected == nil
        result = false
			elsif selected[0].match(/[0-9]/) 
				result = false
			end
    end

    return selected
  end

  def getCelebrity
    celebLength = 7216
    celeb = IO.readlines("#{Rails.root}/lib/seeds/celeblist.txt")[rand(1..celebLength)]
    dirtyString = celeb.to_s
    result = dirtyString.gsub(/\n/, "")
    return result
  end

	def getSanitizedCelebrity
		return getCelebrity.gsub!('_', ' ')
	end
end
