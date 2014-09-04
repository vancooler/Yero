require 'spec_helper'

describe Venue do
  it {should respond_to :email }
  it {should respond_to :name }
  it {should respond_to :address_line_one }
  it {should respond_to :address_line_two }
  it {should respond_to :city }
  it {should respond_to :state }
  it {should respond_to :country }
  it {should respond_to :zipcode }
  it {should respond_to :phone }
  it {should respond_to :dress_code }
  it {should respond_to :age_requirement }
  it {should respond_to :venue_type_id }
  it {should respond_to :longitude }
  it {should respond_to :latitude }
  it {should respond_to :venue_network_id }
  it {should respond_to :web_user_id }

  # let(:venue) { VenueType.new }
  # subject { venue }

  # context "should not be valid without a name" do
  # 	before { venue_type.name = nil }
  # 	it { should_not be_valid }
  # end
end
