Meteor.methods
	registerUser: (formData) ->

		check formData, Object

		if RocketChat.settings.get('Accounts_RegistrationForm') is 'Disabled'
			throw new Meteor.Error 'error-user-registration-disabled', 'User registration is disabled', { method: 'registerUser' }

		else if RocketChat.settings.get('Accounts_RegistrationForm') is 'Secret URL' and (not formData.secretURL or formData.secretURL isnt RocketChat.settings.get('Accounts_RegistrationForm_SecretURL'))
			throw new Meteor.Error 'error-user-registration-secret', 'User registration is only allowed via Secret URL', { method: 'registerUser' }

		RocketChat.validateEmailDomain(formData.email);

		userData =
			email: s.trim(formData.email.toLowerCase())
			password: formData.pass

		userId = Accounts.createUser userData

		RocketChat.models.Users.setName userId, s.trim(formData.name)

		RocketChat.saveCustomFields(userId, formData)

		try
			if userData.email
				Accounts.sendVerificationEmail(userId, userData.email);
		catch error
			# throw new Meteor.Error 'error-email-send-failed', 'Error trying to send email: ' + error.message, { method: 'registerUser', message: error.message }

		return userId
