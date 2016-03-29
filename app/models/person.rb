class Person < ActiveRecord::Base
		self.table_name = 'person'
		include Openmrs

		before_save :before_create
		has_one :provider, foreign_key: :provider_id
		has_one :patient, -> {where voided: 0}, foreign_key: :patient_id, dependent: :destroy
	  has_one :client, -> {where voided: 0}, foreign_key: :patient_id, dependent: :destroy
    has_many :names, -> {where voided: 0}, class_name: 'PersonName', foreign_key: :person_id, dependent: :destroy
    has_many :addresses, -> {where voided: 0}, class_name: 'PersonAddress', foreign_key: :person_id, dependent: :destroy
    has_many :relationships, -> {where voided: 0}, class_name: 'Relationship', foreign_key: :person_a
    has_many :person_attributes, -> {where voided: 0}, class_name: 'PersonAttribute', foreign_key: :person_id
    has_many :observations, -> {where voided: 0}, class_name: 'Observation', foreign_key: :person_id, dependent: :destroy

  def after_void(reason = nil)
    self.client.void(reason) rescue nil
    self.names.each{|row| row.void(reason) }
    self.addresses.each{|row| row.void(reason) }
    self.relationships.each{|row| row.void(reason) }
    self.person_attributes.each{|row| row.void(reason) }
    # We are going to rely on patient => encounter => obs to void those
  end

  def age(today = Date.today)
    return nil if self.birthdate.nil?

    # This code which better accounts for leap years
    patient_age = (today.year - self.birthdate.year) + ((today.month - self.birthdate.month) + ((today.day - self.birthdate.day) < 0 ? -1 : 0) < 0 ? -1 : 0)

    # If the birthdate was estimated this year, we round up the age, that way if
    # it is March and the patient says they are 25, they stay 25 (not become 24)
    birth_date=self.birthdate
    estimate=self.birthdate_estimated
    patient_age += (estimate && birth_date.month == 7 && birth_date.day == 1  &&
        today.month < birth_date.month && self.date_created.year == today.year) ? 1 : 0
  end

  def age_in_months(today = Date.today)
    years = (today.year - self.birthdate.year)
    months = (today.month - self.birthdate.month)
    (years * 12) + months
  end

  def birthdate_for_printing
    birthdate = self.birthdate
    if self.birthdate_estimated
      if birthdate.day == 1 and birthdate.month == 7
        birth_date_string = birthdate.strftime("?/?/%Y")
      elsif birthdate.day==15
        birth_date_string = birthdate.strftime("?/%b/%Y")
      else
        birth_date_string = birthdate.strftime("%d/%b/%Y")
      end
    else
      birth_date_string = birthdate.strftime("%d/%b/%Y")
    end
    birth_date_string
  end

end
