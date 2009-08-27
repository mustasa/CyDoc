class InsurancePolicy < ActiveRecord::Base
  belongs_to :insurance
  belongs_to :patient

  validates_presence_of :insurance

  def to_s
    s = "#{insurance.to_s}"
    s += " ##{number}" unless number.blank?

    return s
  end
end
