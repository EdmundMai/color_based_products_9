class Address < ActiveRecord::Base
  belongs_to :state
  belongs_to :order
  
  def full_name
    [first_name, last_name].compact.join(" ")
  end
  
  def full_street_address
    [street_address, street_address2].compact.join(" ")
  end
  
  def city_state_zipcode
    "#{self.city}, #{self.state.short_name} #{self.zip_code}"
  end
end
