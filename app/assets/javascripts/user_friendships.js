$(document).ready(function() {
	
	$('#add-friendship').click(function(event) {
		event.preventDefault(); //stop the default behavior that happens when clicked
		var addFriendshipBtn = $(this);
		$.ajax({ // ajax request out to our server - post to user friendship path as if we were in page itself, instead of going through all the pages
			url: Routes.user_friendships_path({user_friendship: {friend_id: addFriendshipBtn.data('friendId') }}), // using js-routes
			// jquery will convert friend_id to friendId
			dataType: 'json',
			type: 'POST',
			success: function(e) {
				addFriendshipBtn.hide();
				$('#friend-status').html("<a href='#' class='btn btn-success'>Friendship Requested</a>")
			}
		});
	});
});
