class BusinessHour < ActiveRecord::Base
  belongs_to :venue

  validates :day, :open_time, :close_time, presence: true
  validates :day, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 7 }
end
