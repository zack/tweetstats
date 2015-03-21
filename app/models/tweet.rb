class Tweet < ActiveRecord::Base
  validates :user, presence: true,
                   length: { maximum: 15 }
  validates :text, presence: true,
                   length: { maximum: 140 }
end
