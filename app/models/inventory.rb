class Inventory < ActiveRecord::Base
	self.table_name = 'inventory'
  before_create :set_location

  include Openmrs
	
  def self.stock_levels(year= Date.today.year, month = Date.today.month)

    date = Date.new(year, month)
    i = date.end_of_month
    dates = []

    while i >= date.beginning_of_month
      dates << i.to_date
      i -= 1.day
    end
    dates.reverse!

    @users = User.all
    @tests = Kit.where(status: 'active')

    result = {}
    dates.each do |date|
        result[date] = {} if result[date].blank?
        @users.each do |user|
          result[date][user.username] = {} if result[date][user.username].blank?
          @tests.each do |test|
            result[date][user.username][test.name] = {} if result[date][user.username][test.name].blank?
            result[date][user.username][test.name]["opening_stock"] = user.remaining_stock_by_type(test.name, date)
          end
        end
    end
    result
  end

  def set_location
    self.location_id = Location.current_location.id if self.location_id.blank?
  end
end
