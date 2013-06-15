class UserFriendshipDecorator < Draper::Decorator
  decorates :user_friendship
  delegate_all # if method doesn't exist in decorator, try it on the model that it inherits from (user_friendship)
  # allows us to say user_friendship.friend rather than user_friendship_decorator.model.friend 

  def friendship_state
  	model.state.titleize # makes first letter of every word in the string upcase
  end

  def sub_message
  	case model.state
  	when 'pending'
  		"Friend request pending."
  	when 'accepted'
  		"You are friends with #{model.friend.first_name}."
  	end
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
