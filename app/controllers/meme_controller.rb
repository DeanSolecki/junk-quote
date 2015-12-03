require 'yboss'

class MemeController < ApplicationController
	def build
		@res = {
			:imageUrl => getImageUrl,
			:quote => getQuote,
			:celebrity => getCelebrity
		}
		render json: @res
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
		return "not implemented yet"
	end

	def getCelebrity
		return "not implemented yet"
	end
end

