require 'net/http'
require_relative 'cache'

class TBA_API
  attr_reader :organization, :app_identifier, :version

  @@api_base_url = "https://www.thebluealliance.com/api/v2/"
  def initialize( organization, app_identifier, version )
    @organization, @app_identifier, @version = organization, app_identifier, version
    @cache = Cache.new
  end

  def get_team_list ( page = 1 )
    get_api_resource "#{@@api_base_url}teams/#{page}"
  end

  def get_team ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}"
  end

  def get_team_years_participated ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/years_participated"
  end

  def get_team_media ( team_key, year = nil )
    if year == nil
      get_api_resource "#{@@api_base_url}team/#{team_key}/media"
    else
      get_api_resource "#{@@api_base_url}team/#{team_key}/#{year}/media"
    end
  end

  def get_team_history_events ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/history/events"
  end

  def get_team_history_awards ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/history/awards"
  end

  def get_team_history_robots ( team_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/history/robots"
  end

  def get_team_event_list ( team_key, year )
    get_api_resource "#{@@api_base_url}team/#{team_key}/#{year}/events"
  end

  def get_team_event_awards ( team_key, event_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/event/#{event_key}/awards"
  end

  def get_team_event_awards ( team_key, event_key )
    get_api_resource "#{@@api_base_url}team/#{team_key}/event/#{event_key}/matches"
  end

  def get_event_list ( year )
    get_api_resource "#{@@api_base_url}events/#{year}"
  end

  def get_event ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}"
  end

  def get_event_teams ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/teams"
  end

  def get_event_matches ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/matches"
  end

  def get_event_stats ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/stats"
  end

  def get_event_rankings ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/rankings"
  end

  def get_event_awards ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/awards"
  end

  def get_event_district_points ( event_key )
    get_api_resource "#{@@api_base_url}event/#{event_key}/district_points"
  end

  def get_match ( match_key )
    get_api_resource "#{@@api_base_url}match/#{match_key}"
  end

  def get_district_list ( year )
    get_api_resource "#{@@api_base_url}districts/#{year}"
  end

  def get_district_events ( district_key, year )
    get_api_resource "#{@@api_base_url}district/#{district_key}/#{year}/events"
  end

  def get_district_rankings ( district_key, year )
    get_api_resource "#{@@api_base_url}district/#{district_key}/#{year}/rankings"
  end

  def get_api_resource ( original_url )

    if @cache.exists( original_url )
      return @cache.get( original_url )
    end

    uri = URI( original_url )
    request = Net::HTTP::Get.new( uri )
    request['X-TBA-App-Id'] = "#{@organization}:#{@app_identifier}:#{@version}"

    resource = Net::HTTP.start( uri.hostname, uri.port,
      :use_ssl => uri.scheme == 'https' ) { |http|
      http.request( request )
    }

    case resource
    when Net::HTTPSuccess, Net::HTTPRedirection
      @cache.set( original_url, resource.body )
      resource.body
    else
      resource.value
    end
  end

end
