class Room < ActiveRecord::Base
	self.table_name = 'district'
	
	#Possible client encounters
	
		#Encounter Room assignment
		#Encounter Added to waiting list
		#Encounter Waiting End
		#Encounter Select By Counsellor
		#Obs Room allocation id, Concept id,  Room allocated: room id

end
