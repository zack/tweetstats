class TweetsController < ApplicationController

  def index
    @tweets = Tweet.all

    count = @tweets.count*1.0
    @avg_word_count = 0
    @avg_hashtag_count = 0
    @avg_spell_score = 0

    @tweets.each do |tweet|
      @avg_word_count += tweet.text.split(' ').count/count
      @avg_hashtag_count += tweet.hashtags.split(' ').count/count
      @avg_spell_score += tweet.spell_score/count
    end
  end

  def create
    @tweet = Tweet.new(tweet_params)

    @tweet.save
    redirect_to_@tweet
  end

  def show
    @tweet = Tweet.find(params[:id])
  end

  private
    def tweet_params
      params.require(:tweet).permit(:user, :text)
    end
end
