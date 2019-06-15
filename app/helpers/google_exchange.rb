class GoogleExchange
  include HTTParty
  base_uri 'https://www.googleapis.com'

  def update_token(refresh_token)
    response = self.class.post(
      '/oauth2/v4/token',
      body: {
        client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
        client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
        grant_type: "refresh_token",
        refresh_token: refresh_token
      })
    data = JSON.parse response.body

    unless response.code == 200
      return data
    end

    @user.access_token = data["access_token"]
    @user.save

    data
  end

  def get_calendars(access_token)
    response = self.class.get(
      '/calendar/v3/users/me/calendarList',
      :headers => {
        "Authorization" => "Bearer #{access_token}"
      })
    data = JSON.parse response.body

    unless response.code == 200
      return data
    end

    result = []
    data["items"].each do |calendar_info|
      result.append(
        {
          id: calendar_info["id"],
          name: calendar_info["summary"]
        })
    end

    {calendars: result}
  end

  def get_events(access_token, calendar_id)
    calendar_id = url_encode(calendar_id)
    time = url_encode(DateTime.now.rfc3339)

    response = self.class.get(
      "/calendar/v3/calendars/#{calendar_id}/events?timeMin=#{time}&maxResults=6&maxAttendees=6&orderBy=startTime&singleEvents=true",
      :headers => {
        "Authorization" => "Bearer #{access_token}"
      })
    data = JSON.parse response.body

    unless response.code == 200
      return data
    end

    events = []
    data["items"].each do |event|
      if "dateTime".in? event["start"]
        start = event["start"]["dateTime"]
      else
        start = event["start"]["date"]
      end

      events.append(
        {
          link: event["htmlLink"],
          start: start,
          name: event["summary"]
        })
    end

    {events: events}
  end
end

