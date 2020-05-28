// Subscriptions are created when the trip location page is being shown.
// This subscription can received data related to the trip like comments,
// descriptions, trip locations, etc.
function subscribeToTripLocationChannel(tripLocationId) {
	App.cable.subscriptions.create({channel: 'TripLocationChannel', id: tripLocationId}, {
	  connected: function() {
      console.log("connected");
    },

	  disconnected: function() {
      console.log("disconnected");
    },

	  received: function(data) {
      if (data.action === 'new_comment') {
        // Check if the comment does not exist.
        // This comment can exists if the Ajax request to create the new comment was finished first,
        // before receiving data through this WebSocket.
        if ($("span[data-comment-id='" + data.id + "']").length === 0) {
          $('div.comments div.messages-block').prepend(data.view);
          $('#trip-comment-area').val('');
        }
      }
    }
	});
}
