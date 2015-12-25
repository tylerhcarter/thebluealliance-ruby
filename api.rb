require 'json'
require 'net/http'
require_relative 'cache'

class TBA_API
  attr_reader :organization, :app_identifier, :version

  @@api_base_url = "https://www.thebluealliance.com/api/v2/"

  # Public: Initialize the TheBlueAlliance Ruby API Library
  #
  # organization - The organization/person responsible for making the requests
  # app_identifier - An indentifier for the app/expirement being ran
  # version - The version of the app/expirement being ran
  def initialize( organization, app_identifier, version )
    @organization, @app_identifier, @version = organization, app_identifier, version
    @cache = Cache.new
  end

  # Public: Get a list of team's, paginated based on their team number. Each
  #   page contains teams whose number is between `start = 500 * page` and end
  #   at `end = start + 499`, inclusive.
  #
  # See http://www.thebluealliance.com/apidocs#team-list-request
  #
  # page - The page number to retrieve
  #
  # Examples
  #
  #   team_list = get_team_list( 2 )
  #
  # Returns an array containing hashes with data on each team
  def get_team_list ( page = 1 )
    get_api_resource "#{@@api_base_url}teams/#{page}"
  end

  # Public: Gets information on a specific team.
  #
  # See http://www.thebluealliance.com/apidocs#team-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  #
  # Examples
  #
  #   team = get_team( 'frc3128' )
  #   puts team["rookie_year"];
  #   # => '2010'
  #
  # Returns a hashes with data on the given team
  def get_team ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}"
  end

  # Public: Gets a list of years a given team has participated.
  #
  # See http://www.thebluealliance.com/apidocs#team-years-participated-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  #
  # Examples
  #
  #   puts get_team_years_participated( 'frc3128' )
  #   # => ['2010', '2011', '2012',...]
  #
  # Returns an array with the years the team has participated.
  def get_team_years_participated ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/years_participated"
  end

  # Public: Gets media information relating to a given team. Can be links to
  #   videos or photos.
  #
  # See http://www.thebluealliance.com/apidocs#team-media-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  # year - The year to get information on. Defaults to the current year.
  #
  # Examples
  #
  #   puts get_team_media( 'frc254' )
  #   # => [{"type": "youtube", "details": {}, "foreign_key": "jY6HcQVqLgw"}]
  #
  # Returns an array with hashes of media resources
  def get_team_media ( team_key, year = nil )
    if year == nil
      get_api_resource "#{@@api_base_url}team/#{team_key}/media"
    else
      get_api_resource "#{@@api_base_url}team/#{team_key}/#{year}/media"
    end
  end

  # Public: Gets event history for all events a team has participated in.
  #
  # See http://www.thebluealliance.com/apidocs#team-history-events-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  # year - The year to get information on. Defaults to the current year.
  #
  # Examples
  #
  #   history = get_team_history_events( 'frc3128' )
  #   puts history[1]["name"]
  #   # => 'San Diego Regional'
  #
  # Returns an array with hashes of event information
  def get_team_history_events ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/history/events"
  end

  # Public: Gets award history for all awards a team has received.
  #
  # See http://www.thebluealliance.com/apidocs#team-history-awards-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  # year - The year to get information on. Defaults to the current year.
  #
  # Examples
  #
  #   awards = get_team_history_awards( 'frc3128' )
  #   puts awards[0]["name"]
  #   # => 'Rookie All Star Award'
  #
  # Returns an array with hashes of award information
  def get_team_history_awards ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/history/awards"
  end

  # Public: Gets robot history for all recorded robots for a given team.
  #
  # See http://www.thebluealliance.com/apidocs#team-history-robots-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  # year - The year to get information on. Defaults to the current year.
  #
  # Examples
  #
  #   robots = get_team_history_robots( 'frc3128' )
  #   puts robots[0]["key"]
  #   # => 'frc3128_2016'
  #
  # Returns an array with hashes of robot information
  def get_team_history_robots ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/history/robots"
  end

  # Public: Gets the districts the team has particpated in
  #
  # See http://www.thebluealliance.com/apidocs#team-history-districts-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  #
  # Examples
  #
  #   districts = get_team_history_districts( 'frc1124' )
  #   puts districts["2016"]
  #   # => '2016ne'
  #
  # Returns an array with hashes of robot information
  def get_team_history_districts ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/history/districts"
  end

  # Public: Gets a list of all events attended by a team during a given year
  #
  # See http://www.thebluealliance.com/apidocs#team-events-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  # year - The year to get information on. Defaults to the current year.
  #
  # Examples
  #
  #   events = get_team_events( 'frc3128', 2010 )
  #   puts events[0]["name"]
  #   # => 'San Diego Regional'
  #
  # Returns an array with hashes of event information
  def get_team_event_list ( team_key, year )
    get_api_resource "#{@@api_base_url}team/#{team_key}/#{year}/events"
  end

  # Public: Gets a list of all awards given to a given team at a given event.
  #
  # See http://www.thebluealliance.com/apidocs#team-event-awards-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   awards = get_team_event_awards( 'frc3128', '2010sdc' )
  #   puts awards[0]["name"]
  #   # => 'Rookie All Star Award'
  #
  # Returns an array with hashes of award information
  def get_team_event_awards ( team_key, event_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/event/#{event_key}/awards"
  end

  # Public: Gets all matches played by the given team at the given event.
  #
  # See http://www.thebluealliance.com/apidocs#team-event-matches-request
  #
  # team_key - The team number to get information on, prepended with the program
  #   tag. Example: 'frc3128'
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   matches = get_team_event_matches( 'frc3128', '2010sdc' )
  #   puts matches[0]["comp_level"]
  #   # => 'qm'
  #
  # Returns an array with hashes of match information
  def get_team_event_matches ( team_key, event_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/event/#{event_key}/matches"
  end

  # Public: Gets all events ocurring during a given year.
  #
  # See http://www.thebluealliance.com/apidocs#event-list-request
  #
  # year - The year to get information on.
  #
  # Examples
  #
  #   events = get_event_list( '2010' )
  #   puts events[0]["name"]
  #   # => 'Archimedes Division'
  #
  # Returns an array with hashes of event information
  def get_event_list ( year )
    get_api_resource "#{@@api_base_url}events/#{year}"
  end

  # Public: Gets information on a specific event.
  #
  # See http://www.thebluealliance.com/apidocs#event-request
  #
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   events = get_event( '2016casd' )
  #   puts event["name"]
  #   # => 'San Diego Regional'
  #
  # Returns an array with hashes of match information
  def get_event ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}"
  end

  # Public: Gets list of teams attending a given event.
  #
  # See http://www.thebluealliance.com/apidocs#event-teams-request
  #
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   teams = get_event_teams( '2016casd' )
  #   puts teams[0]["name"]
  #   # => 'Harvard-Westlake School'
  #
  # Returns an array with hashes of team information
  def get_event_teams ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/teams"
  end

  # Public: Gets list of matches at a given event.
  #
  # See http://www.thebluealliance.com/apidocs#event-matches-request
  #
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   teams = get_event_matches( '2015casd' )
  #   puts teams[0]["key"]
  #   # => '2015casd_f1m1'
  #
  # Returns an array with hashes of match information
  def get_event_matches ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/matches"
  end

  # Public: Gets statistics of teams attending a given event.
  #
  # See http://www.thebluealliance.com/apidocs#event-stats-request
  #
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   teams = get_event_stats( '2015casd' )
  #   puts teams["oprs"]["3128"]
  #   # => '25.5194592...'
  #
  # Returns a hash with statistics information
  def get_event_stats ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/stats"
  end

  # Public: Get rankings of teams attending a given event.
  #
  # See http://www.thebluealliance.com/apidocs#event-rankings-request
  #
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   teams = get_event_rankings( '2015casd' )
  #   puts teams[15][1]
  #   # => '3128'
  #
  # Returns an array containing arrays of ranking information
  def get_event_rankings ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/rankings"
  end

  # Public: Gets list of awards given at a given event.
  #
  # See http://www.thebluealliance.com/apidocs#event-awards-request
  #
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   teams = get_event_awards( '2015casd' )
  #   puts teams[0]["name"]
  #   # => 'Regional Chairman's Award'
  #
  # Returns an array with hashes of award information
  def get_event_awards ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/awards"
  end

  # Public: Gets list of district points awarded from an event.
  #
  # See http://www.thebluealliance.com/apidocs#event-points-request
  #
  # event_key - The event code given by US FIRST to an event, prepended by the
  #   year that the event occured. Example: '2016casd'
  #
  # Examples
  #
  #   data = get_event_district_points( '2014cthar' )
  #   puts data["points"]["frc95"]["award_points"]
  #   # => '5'
  #
  # Returns an array with hashes of district point information
  def get_event_district_points ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/district_points"
  end

  # Public: Gets information on a specific match.
  #
  # See http://www.thebluealliance.com/apidocs#match-request
  #
  # match_key - The match to get information on. Includes the event key,
  #   competition level, and number. Example: '2014cmp_f1m1'
  #
  # Examples
  #
  #   data = get_match( '2014cmp_f1m1' )
  #   puts data["time_string"]
  #   # => '5:38 PM'
  #
  # Returns a hash with the match information
  def get_match ( match_key )
    get_api_resource "#{@@api_base_url}match/#{match_key}"
  end

  # Public: Gets all active districts on a given year.
  #
  # See http://www.thebluealliance.com/apidocs#district-list-request
  #
  # year - The year to get information on.
  #
  # Examples
  #
  #   districts = get_district_list( '2015' )
  #   puts districts[0]["name"]
  #   # => 'Michigan'
  #
  # Returns an array with hashes of district information
  def get_district_list ( year )
    get_api_resource "#{@@api_base_url}districts/#{year}"
  end

  # Public: Gets a list of events ocurring in a given district in a given year.
  #
  # See http://www.thebluealliance.com/apidocs#district-events-request
  #
  # district_key - The letter code for the district to get information on.
  #   Examples: 'ne', 'in', 'mar'
  # year - The year to get information on.
  #
  # Examples
  #
  #   events = get_district_events( 'ne', '2014' )
  #   puts events[0]["name"]
  #   # => 'New England FRC Region Championship'
  #
  # Returns an array with hashes of district event information
  def get_district_events ( district_key, year )
    get_api_resource "#{@@api_base_url}district/#{district_key}/#{year}/events"
  end

  # Public: Gets a rank of teams participating in a district.
  #
  # See http://www.thebluealliance.com/apidocs#district-rankings-request
  #
  # district_key - The letter code for the district to get information on.
  #   Examples: 'ne', 'in', 'mar'
  # year - The year to get information on.
  #
  # Examples
  #
  #   events = get_district_rankings( 'ne', '2014' )
  #   puts events[0]["team_key"]
  #   # => 'frc195'
  #
  # Returns an array with hashes of district event information
  def get_district_rankings ( district_key, year )
    get_api_resource "#{@@api_base_url}district/#{district_key}/#{year}/rankings"
  end

  # Public: Gets a list of teams participating in a district.
  #
  # See http://www.thebluealliance.com/apidocs#district-teams-request
  #
  # district_key - The letter code for the district to get information on.
  #   Examples: 'ne', 'in', 'mar'
  # year - The year to get information on.
  #
  # Examples
  #
  #   teams = get_district_teams( 'ne', '2014' )
  #   puts teams[0]["rookie_year"]
  #   # => '2003'
  #
  # Returns an array with hashes of district teams information
  def get_district_teams ( district_key, year )
    get_api_resource "#{@@api_base_url}district/#{district_key}/#{year}/teams"
  end

  # Internal: Retrieves a resource from the API server
  #
  # url - The URL being requested
  #
  # Examples
  #
  #   data = get_api_resource( "http://example.com/api/v2/teams/1" )
  #
  # Returns a JSON parsed dataset from the resource.
  def get_api_resource ( url )

    if @cache.exists( url )
      return @cache.get( url )
    end

    uri = URI( url )
    request = Net::HTTP::Get.new( uri )
    request['X-TBA-App-Id'] = "#{@organization}:#{@app_identifier}:#{@version}"

    resource = Net::HTTP.start( uri.hostname, uri.port,
      :use_ssl => uri.scheme == 'https' ) { |http|
      http.request( request )
    }

    case resource
    when Net::HTTPSuccess, Net::HTTPRedirection
      data = JSON.parse( resource.body )
      @cache.set( url, data )
      return data
    else
      resource.value
    end
  end

end
