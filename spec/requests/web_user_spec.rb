require 'spec_helper'

describe 'Web User' do
	subject { page }

	describe "Home Page" do
		before { visit root_path }

		it {should have_content('Yero')}

		context "for signed-in users" do
			let(:web_user) { FactoryGirl.create(:web_user)}
			before(:each) {sign_in user}

			describe "dashboard" do
				it {should have_content('dashboard')}
				it { should have_link("Venues", href: web_user_venues_path(user)) }
				it { should have_link("Add Venue", href: new_web_user_venues_path(user)) }
			end
		end

		describe "for non-signed-in users" do
			it { should have_link("Register", href: new_web_user_path) }
		end
	end
end