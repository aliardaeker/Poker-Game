$VERBOSE = nil
require './ProxyAPI'
require "openssl"

# Network proxy is implemented for rereiving user data
class UserDataProxy < ProxyAPI
	OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
	
	def makeUrl()
		@url = "https://randomuser.me/api/"
	end
	
	def createObject()
		@userData = @object['results'][0]['name']['first']
	end
	
	def getUserData()
		self.makeUrl()
		
		if (self.makeRequest())
			self.createObject()
			@userData
		else
			@userData = -1
		end
	end
end