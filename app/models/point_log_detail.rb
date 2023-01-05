class PointLogDetail < ActiveRecord::Base
  belongs_to :point_log

  def value=(arg)
    write_attribute :value, normalize(arg)
  end

  def old_value=(arg)
    write_attribute :old_value, normalize(arg)
  end

  private

  def normalize(val)
    case val
    when true
      '1'
    when false
      '0'
    when Date
      val.strftime('%Y-%m-%d')
    else
      val
    end
  end
end
