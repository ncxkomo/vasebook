class UserFriendship < ActiveRecord::Base
	belongs_to :user 
	belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

	attr_accessible :user, :friend, :user_id, :friend_id, :state

	state_machine :state, initial: :pending do    
		after_transition on: :accept, do: [:send_acceptance_email]

		state :requested

		event :accept do 
			transition any => :accepted
		end
	end

	def self.request(requester, requestee) 
		transaction do 
			@friendship1 = create!(user: requester, friend: requestee, state: 'pending')
			@friendship2 = create!(user: requestee, friend: requester, state: 'requested')
		end

		@friendship1.send_request_email
		@friendship1
	end

	def send_request_email
		UserNotifier.friend_requested(id).deliver
	end   

	def send_acceptance_email
		UserNotifier.friend_accepted(id).deliver
	end

end
