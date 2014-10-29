class User < ActiveRecord::Base
  include Openmrs

  before_save :encrypt_password, :before_create

  has_many :user_roles, foreign_key: "user_id", dependent: :destroy
  belongs_to :person, -> { where voided: 0 }, foreign_key: :person_id
  has_many :user_properties, foreign_key: :user_id # no default scope
  has_one :activities_property, -> { where('property = ?', 'Activities') }, class_name: 'UserProperty',
          foreign_key: :user_id

  #cattr_accessor :current_user_id

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
    if self.current_user_id
      User.find(self.current_user_id)
    else
      nil
    end
  end

  def first_name
    self.person.names.first.given_name rescue ''
  end

  def last_name
    self.person.names.first.family_name rescue ''
  end

  def name
    name = self.person.names.first
    "#{name.given_name} #{name.family_name}" rescue ""
  end

  def self.current_user_id
    Thread.current[:user]
  end

  def self.current_user_id=(user_id)
    Thread.current[:user] = user_id
  end

  def self.current
    self.find(self.current_user_id)
  end

  def remaining_stock_by_type(kit_type, date = Date.today)
    result = 0
    plus_types = ["Distribution"].collect { |iv_name| InventoryType.find_by_name(iv_name).id }
    minus_types = ["Expires", "Losses", "Usage",].collect { |iv_name| InventoryType.find_by_name(iv_name).id }

    CouncillorInventory.find_by_sql(
          ["SELECT ci.id, ci.value_numeric, ci.inventory_type FROM councillor_inventory ci
            INNER JOIN inventory iv ON ci.voided = 0 AND iv.voided = 0 AND iv.lot_no = ci.lot_no
            AND iv.kit_type = ? AND DATE(iv.date_of_expiry) > ?
          WHERE ci.councillor_id = ? GROUP BY ci.id",
           Kit.find_by_name(kit_type).id, date.to_date, self.id,]).each do |iv|
          if plus_types.include?(iv.inventory_type)
            result = result + iv.value_numeric.to_i
          elsif minus_types.include?(iv.inventory_type)
            result = result - iv.value_numeric.to_i
          end
    end
    result
  end

end

