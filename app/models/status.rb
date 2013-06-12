class Status < ActiveRecord::Base
  attr_accessible :content, :user_id
  belongs_to :user

  validates :content, presence: :true,
  					  length: { 
  					  	minimum: 2,
  					  	message: "Must contain more than one character."
  					  }

  validates :user_id, presence: :true
  					  
end
