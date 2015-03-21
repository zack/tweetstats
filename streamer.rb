# Tweets: https://dev.twitter.com/overview/api/tweets
# Entities: https://dev.twitter.com/overview/api/entities
# Twitter Gem: http://www.rubydoc.info/gems/twitter

require 'tweetstream'
require 'sqlite3'
require 'ffi/aspell'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

db = SQLite3::Database.open "db/development.sqlite3"
insert_new_tweet = db.prepare "INSERT INTO Tweets (user, text, hashtags, \
                              spell_score, tweet_time, created_at, updated_at) \
                              VALUES (?, ?, ? ,?, ?, ?, ?)"
count = 0

arr = []

db.execute "BEGIN TRANSACTION"
client.sample do |object|
  if object.is_a?(Twitter::Tweet) and object.lang == 'en'

    # Get all of the data
    time = Time.now
    user = object.user.screen_name
    text = object.text.inspect[1..-2]
    tweet_time = DateTime.parse("#{object.created_at}").to_time.to_i

    # Get the hashtags
    if object.hashtags.length > 0
      hashtags = ''
      object.hashtags.each do |hashtag|
        hashtags << hashtag.text << ' '
      end
      hashtags.strip!
    end

    # Get the spell score
    excused = ['RT']
    num = 0
    den = 0
    text.split(' ').each do |word|
      if /^[a-zA-Z]+$/ =~ word and !excused.include?(word)
        den += 1
        FFI::Aspell::Speller.open('en_US') do |speller|
          if speller.correct?(word)
            num += 1
          end
        end
      end
    end

    if den == 0
      spell_score = 100
    else
      spell_score = num*1.0/den*100
    end

    # Make a DB insert
    insert_new_tweet.execute "#{user}",
                             "#{text}",
                             "#{hashtags}",
                             "#{spell_score}",
                             "#{tweet_time}",
                             "#{time}",
                             "#{time}"
    count+=1
    if count == 100
      db.execute "COMMIT TRANSACTION"
      db.execute "BEGIN TRANSACTION"
      count = 0
    end
  end
end
