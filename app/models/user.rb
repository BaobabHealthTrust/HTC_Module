class User < ActiveRecord::Base
	include Openmrs
	
	before_save :encrypt_password, :before_create
	
	def encrypt_password
		self.salt = BCrypt::Engine.generate_salt
		self.password = BCrypt::Engine.hash_secret(password, salt)
	end

	def self.authenticate(username, password)

		user = User.where(username: username).first
		if user && user.password == BCrypt::Engine.hash_secret(password, user.salt)
			user
		else
			nil
		end
	end
	
	def self.current
		User.first
	end

end

