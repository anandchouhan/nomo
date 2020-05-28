// Find friends event
$(document).on('click', '#fr-req', function() {
  gtag('event', 'Find Friends', {
    'event_category': 'Find Friends',
  });
});

// Plan trip event
$(document).on('click', '#plan-a-trip-btn', function() {
  gtag('event', 'Plan a Trip', {
    'event_category': 'Plan a Trip',
  });
});

// Open notifications event
$(document).on('click', '#notifications', function() {
  gtag('event', 'Notification', {
    'event_category': 'Notifications',
  });
});

// Add friend event
$(document).on('click', '.add-connected-btn', function() {
  gtag('event', 'Add friend', {
    'event_category': 'Add friend',
  });
});

// Cancel friend request event
$(document).on('click', '.cancel-sent-friend-request', function() {
  gtag('event', 'Cancel friend request', {
    'event_category': 'Cancel',
  });
});

// Decline friend request event
$(document).on('click', '.decline-friend-request', function() {
  gtag('event', 'Decline friend request', {
    'event_category': 'Decline',
  });
});

// Accept friend request event
$(document).on('click', '.approve-friend-request-btn', function() {
  gtag('event', 'Accept friend request', {
    'event_category': 'Accept',
  });
});

// Create comment on feed event
$(document).on('click', '.submit-comment', function() {
  gtag('event', 'Commented', {
    'event_category': 'Comment',
  });
});

// Add trip from calendar event
$(document).on('click', '#add-trip-calendar', function() {
  gtag('event', 'Add trip module from calendar', {
    'event_category': 'Add a trip',
  });
});

// Add trip from profile event
$(document).on('click', '#add-trip-profile', function() {
  gtag('event', 'Add trip module from profile', {
    'event_category': 'Add a trip',
  });
});
