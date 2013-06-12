require 'test_helper'

class StatusTest < ActiveSupport::TestCase

  test "that a status requires content" do 
  	status = Status.new
  	assert !status.save
  	assert !status.errors[:content].empty?
  end

  test "that a status requires at least two characters" do 
  	status = Status.new(content: "Y")
  	assert !status.save
  	assert status.errors[:content].include?("Must contain more than one character.")
  end

  test "that a status has a user id" do 
  	status = Status.new(content: "Yo.")
  	assert !status.save
  	assert !status.errors[:user_id].empty?
  end
  

end
