# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#Creating Default Test Kits
puts "Loading default tesk kits"
 [["Determine", "HIV-1/2 rapid test kit", 10], ["UniGold", "HIV Test kit", 10]].each_with_index{|test, i|
   next if !Kit.find_by_name(test[0]).blank?
   Kit.create(name: test[0], description: test[1], creator: 1, flow_order: (i + 1), status: "active", duration: test[2])
 }

puts "Loading default inventory types"
[["Delivery", "Type for creating new batch deliveries"],
 ["Distribution", "For councillor batch assignment"],
 ["Usage", "To record used kits"],
 ["Losses", "For recording damaged batches"],
 ["Expires", "For verifying expired kits"]
].each_with_index{|test, i|
  next if !InventoryType.find_by_name(test[0]).blank?
  InventoryType.create(name: test[0], description: test[1], creator: 1)
}