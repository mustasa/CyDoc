class EsrFile < ActiveRecord::Base
  has_attachment :storage => :file_system
  has_many :esr_records, :dependent => :destroy
  
  def to_s(format = :default)
    case format
    when :short
      "#{updated_at.strftime('%d.%m.%Y')}: #{esr_records.count} Buchungen"
    else
      s = ''
      esr_records.each {|record|
        s += record.to_s + "\n"
      }
      s
    end
  end

  VESR_DIR = File.join(RAILS_ROOT, 'data', 'vesr')

  def self.esr_files
    Dir.new(VESR_DIR).select{|entry| !(entry.starts_with?('.') or entry.starts_with?('archive'))}.map{|name| File.new(File.join(VESR_DIR, name))}
  end

  after_save :create_records

  private
  def create_records
    File.new(full_filename).each {|line|
      self.esr_records << EsrRecord.new.parse(line) unless line[0..2] == '999'
    }
  end
end
