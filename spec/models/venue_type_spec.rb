require 'spec_helper'

describe VenueType do
  it {should respond_to :name}

  let(:venue_type) { VenueType.new }
  subject { venue_type }

  context "should not be valid without a name" do
  	before { venue_type.name = nil }
  	it { should_not be_valid }
  end
end
