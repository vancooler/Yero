class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, polymorphic: true
  validates_presence_of :user
  after_save :set_since_1970

  # TODO: scope time once clarified
  def self.at_venue_tonight(venue_id)
    venue = Venue.find(venue_id)
    if venue
      rooms = venue.rooms
      if rooms
        venue_beacons_ids = []
        rooms.each do |room|
          venue_beacons_ids += room.beacons.pluck(:id)
        end # rooms.each

        # get activities for all beacons in the venue
        where(trackable_id: venue_beacons_ids)

        # and today's activities only (just set time below to proposed start and end of a nightly..)
        where("created_at >= :start_date AND created_at <= :end_date", start_date: Time.now.beginning_of_day, end_date: Time.now.end_of_day)
      else #if rooms
        []
      end
    else #if venue
      []
    end
  end
 
  private
    def set_since_1970
      if self.since_1970.blank?
        self.update(since_1970: (self.created_at - Time.new('1970')).seconds.to_i)
      end
    end
end
