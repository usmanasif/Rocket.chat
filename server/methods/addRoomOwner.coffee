Meteor.methods
	addRoomOwner: (rid, userId) ->
		unless Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', 'Invalid user', { method: 'addRoomOwner' }
	 
		check rid, String
		check userId, String

		unless RocketChat.authz.hasPermission Meteor.userId(), 'set-owner', rid
			throw new Meteor.Error 'error-not-allowed', 'Not allowed', { method: 'addRoomOwner' }

		subscription = RocketChat.models.Subscriptions.findOneByRoomIdAndUserId rid, userId
		console.log subscription
		unless subscription?
			throw new Meteor.Error 'error-invalid-room', 'Invalid room', { method: 'addRoomOwner' }

		console.log RocketChat.models.Subscriptions.addRoleById(subscription._id, 'owner')

		user = RocketChat.models.Users.findOneById userId
		fromUser = RocketChat.models.Users.findOneById Meteor.userId()
		console.log RocketChat.models.Messages.createSubscriptionRoleAddedWithRoomIdAndUser rid, user,
			u:
				_id: fromUser._id
				username: fromUser.username
			role: 'owner'

		if RocketChat.settings.get('UI_DisplayRoles')
			RocketChat.Notifications.notifyAll('roles-change', { type: 'added', _id: 'owner', u: { _id: user._id, username: user.username }, scope: rid });

		return true
