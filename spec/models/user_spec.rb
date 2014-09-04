require 'spec_helper'
describe User do

	it {should respond_to :first_name}
	it {should respond_to :gender}
	it {should respond_to :birthday}
	it {should respond_to :user_avatars}

	let (:user) {User.new(first_name: "Alex", gender:"M",
												birthday: Date.today - 28.years )}
	subject { user }

	context "When first name is missing" do
		before {user.first_name = nil}
		it { should_not be_valid }
	end

	context "When birthday is missing" do
		before {user.birthday = nil}
		it { should_not be_valid }
	end

	context "When gender is missing" do
		before {user.gender = nil}
		it { should_not be_valid }
	end
end