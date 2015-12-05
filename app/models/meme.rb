class Meme
  attr_reader :imageUrl, :quote, :celebrity

  def initialize
    @imageUrl = getImageUrl
    @quote = getQuote
    @celebrity = getCelebrity
  end

  private 

  def getImageUrl
    YBoss::Config.instance.oauth_key = 'dj0yJmk9UThhRWk4a1hJUnJpJmQ9WVdrOWJtaDBSa3BNTnpJbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD0wMQ--'
    YBoss::Config.instance.oauth_secret = '76521200fefdf62d666b6d8e19908302d2cc9e73'
    rand = Random.new
    noun = IO.readlines("#{Rails.root}/lib/seeds/nounlist.txt")[rand(1..2327)]
    @res = YBoss.images('q' => noun, 'format' => 'json', 'count' => '1', 'start' => rand(1..1000).to_s, 'dimensions' => 'medium')
    @imageUrl = @res.items[0].url
  end

  def getQuote
    tries = 0;
    result = '';

    while tries <= 5
      tries += 1
      res = HTTParty.get('https://en.wikiquote.org/w/api.php?format=json&action=parse&page=Bob_Seger')
      data = res['parse']['text']['*']
      xpathData = Nokogiri::HTML data
      if xpathData.css("span[id='Quotes']").text == 'Quotes'
        result = 'Good'
      else
        result = 'Bad'
      end
      #rawQuotes = xpathData.xpath("//ul/li").map{|data_node| data_node.text}
      break if result == 'Good'
    end
    
    return result
  end

  def getCelebrity
    return "not implemented yet"
  end
end
