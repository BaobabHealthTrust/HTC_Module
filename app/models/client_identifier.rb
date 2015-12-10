class ClientIdentifier < ActiveRecord::Base
	self.table_name = 'patient_identifier'
	self.primary_key = 'patient_identifier_id'
	include Openmrs

	before_save :before_create

  def self.calculate_checkdigit(number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    # Same algorithm used by PIH (except they allow characters)
    number = number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2==parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end
    
    checkdigit = 0
    checkdigit = checkdigit +1 while ((sum+(checkdigit))%10)!=0
    return checkdigit
  end

  def self.next_htc_number
    identifiers = self.where("RIGHT(identifier,4) = ? AND identifier_type = ?",
      Date.today.year,ClientIdentifierType.find_by_name('HTC Identifier').id).map(&:identifier)
    return "1-#{Date.today.year}" if identifiers.blank?
    return (identifiers.sort.last.sub("-#{Date.today}",'').to_i + 1).to_s + "-#{Date.today.year}"
  end

end
