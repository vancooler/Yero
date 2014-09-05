require 'spec_helper'
describe UserRegistration do

	it 'increases the number of users by one' do
		user_registration = UserRegistration.new(
				first_name: "Maria",
				gender: 		"F",
				birthday: 	Date.today - 20.years,
			)
		expect { user_registration.create }.to change { User.count }.by(1)
	end

	it 'should return an error if an avatar is not provided'
end