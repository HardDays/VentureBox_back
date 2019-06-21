module GraphHelper

  def self.next_date(date, type)
    if type == 'day'
      return (date + 1.hour)
    elsif type == 'week'
      return date.next_day(1)
    elsif type == 'month'
      return date.next_day(1)
    elsif type == 'year'
      return date.next_month(1)
    end
  end

  def self.to_time(date, type)
    if type == 'day'
      return date.end_of_hour
    elsif type == 'week'
      return date.end_of_day
    elsif type == 'month'
      return date.end_of_day
    elsif type == 'year'
      return date.end_of_month
    end
  end

  def self.date_range(type)
    if type == 'month'
      return (DateTime.now.end_of_day - 1.month)..DateTime.now.end_of_day
    elsif type == 'year'
      return (DateTime.now.end_of_month - 1.year)..DateTime.now.end_of_month
    end
  end

  def self.axis_dates(type)
    axis = []
    _date_range = date_range(type)

    date = _date_range.first
    while date.in? _date_range do
      axis.push(to_time(date, type))
      date = next_date(date, type)
    end

    return axis
  end

  def self.custom_axis_dates(step, dates)
    axis = []
    _date_range = dates[0]..dates[1]

    date = _date_range.first
    while date.in? _date_range do
      axis.push(to_time(date, step))
      date = next_date(date, step)
    end

    return axis
  end

  def self.axis(type)
    axis = []
    _date_range = date_range(type)

    date = _date_range.first
    while date.in? _date_range do
      axis.push(to_time(date, type).beginning_of_hour.strftime(type_str(type)))
      date = next_date(date, type)
    end

    return axis
  end

  def self.custom_axis(step, dates)
    axis = []
    _date_range = dates[0]..dates[1]

    date = _date_range.first
    while date.in? _date_range do
      axis.push(to_time(date, step).beginning_of_hour.strftime(type_str(step)))
      date = next_date(date, step)
    end

    return axis
  end

  def self.type_str(type)
    if type == 'day'
      return "%H:%M"
    elsif type == 'week'
      return "%e/%b"
    elsif type == 'month'
      return "%e/%b"
    elsif type == 'year'
      return "%b/%y"
    end
  end

end
