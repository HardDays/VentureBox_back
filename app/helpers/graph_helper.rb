module GraphHelper

  def self.next_date(date, step)
    if step == 'hour'
      return (date + 1.hour)
    elsif step == 'day'
      return date.next_day(1)
    elsif step == 'week'
      return date.next_day(1)
    elsif step == 'month'
      return date.next_month(1)
    elsif step == 'year'
      return date.next_year(1)
    end
  end

  def self.to_the_end(date, step)
    if step == 'hour'
      return date.end_of_hour
    elsif step == 'day'
      return date.end_of_day
    elsif step == 'week'
      return date.end_of_day
    elsif step == 'month'
      return date.end_of_month
    elsif step == 'year'
      return date.end_of_year
    end
  end

  def self.date_range(type)
    if type == 'month'
      return (DateTime.now.end_of_day - 1.month)..DateTime.now.end_of_day
    elsif type == 'year'
      return (DateTime.now.end_of_month - 1.year)..DateTime.now.end_of_month
    end
  end

  def self.axis_dates(date_range_type, step)
    axis = []
    _date_range = date_range(date_range_type)

    date = _date_range.first
    while date.in? _date_range do
      axis.push(to_the_end(date, step))
      date = next_date(date, step)
    end

    return axis
  end

  def self.custom_axis_dates(dates, step)
    axis = []

    date = dates[0]
    while date >= dates[0] and date <= dates[1] do
      axis.push(to_the_end(date, step))
      date = next_date(date, step)
    end

    return axis
  end

  def self.axis(date_range_type, step)
    axis = []
    _date_range = date_range(date_range_type)

    date = _date_range.first
    while date.in? _date_range do
      axis.push(to_the_end(date, step).beginning_of_hour.strftime(date_to_axis_str(step)))
      date = next_date(date, step)
    end

    return axis
  end

  def self.custom_axis(dates, step)
    axis = []

    date = dates[0]
    while date >= dates[0] and date <= dates[1] do
      axis.push(to_the_end(date, step).beginning_of_hour.strftime(date_to_axis_str(step)))
      date = next_date(date, step)
    end

    return axis
  end

  def self.date_to_axis_str(step)
    if step == 'hour'
      return "%H:%M"
    elsif step == 'day'
      return "%e/%b"
    elsif step == 'week'
      return "%e/%b"
    elsif step == 'month'
      return "%b/%y"
    elsif step == 'year'
      return "%Y"
    end
  end

  def self.get_all_period_info(created_at)
    dates = [created_at, DateTime.now]
    diff = Time.diff(dates[0], dates[1])
    if diff[:year] > 0
      new_step = 'year'
      dates[1] = dates[1].end_of_year
    elsif diff[:month] > 0
      new_step = 'month'
      dates[1] = dates[1].end_of_month
    elsif diff[:week] > 0
      new_step = 'day'
      dates[1] = dates[1].end_of_day
    elsif diff[:day] > 0
      new_step = 'day'
      dates[1] = dates[1].end_of_day
    else
      new_step = 'hour'
      dates[1] = dates[1].end_of_hour
    end

    axis = custom_axis(dates, new_step)
    date_range = custom_axis_dates(dates, new_step)

    return axis, date_range, new_step
  end

end
