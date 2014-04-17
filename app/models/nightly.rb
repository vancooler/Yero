class Nightly < ActiveRecord::Base
  belongs_to :venue

  def is_for_today
    if created_at.to_date === Date.today || (Time.now.beginning_of_day + 5.hours > (Time.now && created_at - 1.day).to_date === Date.today)
      return true
    end
  end
end
