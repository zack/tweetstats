class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :user, null: false
      t.text :text, null: false
      t.text :hashtags
      t.integer :spell_score, null: false
      t.integer :tweet_time, null: false

      t.timestamps null: false
    end
  end
end
