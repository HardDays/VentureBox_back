module GraphHelper

  def self.date_step(type)
    if type == 'day'
      return 1.hour
    elsif type == 'week'
      return 1.day
    elsif type == 'month'
      return 1.day
    elsif type == 'year'
      return 1.month
    end
  end

  def self.date_range(type)
    if type == 'month'
      return (DateTime.now.end_of_day - 1.month).to_i..DateTime.now.end_of_day.to_i
    elsif type == 'year'
      return (DateTime.now.end_of_month - 1.year).to_i..DateTime.now.end_of_month.to_i
    end
  end

  def self.axis_dates(type)
    axis = []
    (date_range(type)).step(date_step(type)).each { |v|
      axis.push(Time.at(v).end_of_day)
    }

    return axis
  end

  def self.custom_axis_dates(step, dates)
    axis = []
    (dates[0].to_i..dates[1].to_i).step(date_step(step)).each { |v|
      axis.push(Time.at(v).end_of_day)
    }

    return axis
  end

  def self.axis(type)
    axis = []
    (date_range(type)).step(date_step(type)).each { |v|
      axis.push(Time.at(v).end_of_day.strftime(type_str(type)))
    }

    return axis
  end

  def self.custom_axis(step, dates)
    axis = []
    (dates[0].to_i..dates[1].to_i).step(date_step(step)).each { |v|
      axis.push(Time.at(v).end_of_day.strftime(type_str(step)))
    }

    return axis
  end

  def self.type_str(type)
    if type == 'day'
      return "%H"
    elsif type == 'week'
      return "%e/%b"
    elsif type == 'month'
      return "%e/%b"
    elsif type == 'year'
      return "%b/%y"
    end
  end

end
