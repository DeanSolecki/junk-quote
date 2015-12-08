class Meme
  attr_reader :imageUrl, :quote, :celebrity

  def initialize
    @imageUrl = getImageUrl
    @quote = getQuote
    @celebrity = getCelebrity
  end

  private 

  def getImageUrl
    # Config yahoo api.
    YBoss::Config.instance.oauth_key = <%= ENV['YBOSS_KEY'] %>
    YBoss::Config.instance.oauth_secret = <%= ENV['YBOSS_KEY'] %>
    rand = Random.new

    # Grab a random noun from list and query image search with it.
    noun = IO.readlines("#{Rails.root}/lib/seeds/nounlist.txt")[rand(1..2327)]
    @res = YBoss.images('q' => noun, 'format' => 'json', 'count' => '1', 'start' => rand(1..1000).to_s, 'dimensions' => 'medium')
    @imageUrl = @res.items[0].url
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

      # Parse quotes and make sure length is at least 1
      rawQuotes = xpathData.xpath("//ul/li").map{|data_node| data_node.text}
      rawQuotes.each do |quote|
        if match = quote.match(/(.+?)\n\n/)
          rawQuote = $1
          strippedQuote = rawQuote.gsub(/\"/, "'")
          quotes << strippedQuote
        end
      end
      if quotes.length < 1
        result = false
      else
        result = true
      end

      selected = quotes[rand(0..(quotes.length))]

      if selected == nil
        result = false
      else
        result = true
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
end
