require 'json'
require 'open-uri'

# Abstract api class which is implemented by poker and userData classes
class ProxyAPI
	def initialize()
		@url = ""
	end
	
	def makeUrl()
		raise NoMethodError
	end
	
	def createObject
		raise NoMethodError
	end
	
	# Request are made here
	def makeRequest
		result = open(@url)
		response_status = result.status
		
		# Fallback occurs according to response status
		if (response_status[0] == "200")
			output = StringIO.new
			output = result

			@object = JSON.parse(result.string)
			return true
		else
			puts("Error in api connection.")
			puts("Response Status: " + response_status[0])
			puts("Response Message: " + response_status[1])
			return false
		end
	end
end