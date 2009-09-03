class ServiceRecord < ActiveRecord::Base
  belongs_to :provider, :class_name => 'Doctor'
  belongs_to :biller, :class_name => 'Doctor'
  belongs_to :responsible, :class_name => 'Doctor'

  belongs_to :vat_class
  named_scope :full_vat, :conditions => {:vat_class_id => VatClass.full}
  named_scope :reduced_vat, :conditions => {:vat_class_id => VatClass.reduced}
  named_scope :excluded_vat, :conditions => {:vat_class_id => VatClass.excluded}
  
  belongs_to :patient

  has_and_belongs_to_many :invoices
  has_and_belongs_to_many :sessions
  
  # Validation
  validates_presence_of :date, :code, :tariff_type, :session, :quantity, :unit_tt, :unit_mt, :unit_factor_tt, :unit_factor_mt

  def validate_for_invoice
    errors.add_to_base("Position '#{code}' verlangt Referenzcode") unless valid_ref_code?
  end

  def valid_for_invoice?
    valid?
    validate_for_invoice
    
    errors.empty?
  end
  
  def to_s(format = :default)
    case format
    when :stats
      "#{date.strftime('%d.%m.%Y')}: #{quantity}x #{code} #{!ref_code.nil? ? '(' + ref_code + ') ' : ''}- #{text}"
    else
      "#{sprintf('%03i', tariff_type)} - #{quantity}x #{code} #{!ref_code.nil? ? '(' + ref_code + ') ' : ''}- #{text}"
    end
  end
  
  # TODO: lookup in tarmed db
  def needs_ref_code?
    text.starts_with?('+')
  end
  
  def valid_ref_code?
    not (needs_ref_code? and read_attribute(:ref_code).nil?)
  end
  
  def ref_code
    valid_ref_code? ? read_attribute(:ref_code) : "Fehlende Referenz"
  end
  
  # Calculated field
  def rounded_amount_mt
    (quantity * amount_mt * unit_factor_mt * unit_mt).round(2)
  end
  
  def rounded_amount_tt
    (quantity * amount_tt * unit_factor_tt * unit_tt).round(2)
  end
  
  def amount
   rounded_amount_mt + rounded_amount_tt
  end

  def text
    remark
  end
end
