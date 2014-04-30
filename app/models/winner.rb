class Winner < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue

  before_create :create_key

  # create a unique key for API usagebefore create
  def create_key
    self.winner_id = loop do
      random_token = rand.to_s[2..6]
      break random_token unless Winner.exists?(winner_id: random_token)
    end
  end
end