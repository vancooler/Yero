class Poke < ActiveRecord::Base
  # A 'poke' is a generic way of sending a request from one user to another

  belongs_to :pokee, :class_name => 'User'
  belongs_to :poker, :class_name => 'User'
end