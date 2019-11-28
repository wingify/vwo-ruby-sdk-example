require 'sinatra'
require 'vwo'
require_relative 'user_storage'
require 'haml'
require "json"
require 'time'
require 'erb'
config = JSON.load(File.open(File.join(File.dirname(__FILE__), 'config/vwo.json')))

USERS = %w(Ashley Bill Chris Dominic Emma Faizan Gimmy Harry Ian John King Lisa Mona Nina Olivia Pete Queen Robert Sarah Tierra Una Varun Will Xin You Zeba)

ab_test_campaign_key = config['ab_test_campaign_key']
ab_test_campaign_goal = config['ab_test_campaign_goal']

# Basic Logging Before Starting App
class VWO
  class Logger
    def initialize(logger_instance)
      # Only log info logs and above, no debug
      @@logger_instance = logger_instance || ::Logger.new(STDOUT, level: :info)
    end

    def log(level, message)
      # Basic Modification
      message = "#{Time.now} #{message}"
      @@logger_instance.log(level, message)
    end
  end
end

$vwo_client_instance = VWO.new(config['account_id'], config['sdk_key'], nil, nil, false)
$vwo_client_instance_user_storage = VWO.new(config['account_id'], config['sdk_key'], nil, VWO::UserStorage.new, false)

# Logging After Starting App
def start_logger
  VWO::Logger.class_eval do
    # Override this method to handle logs in a #{ab_test_campaign_goal} manner
    def log(level, message)
      # Modify message for #{ab_test_campaign_goal} logging
      message = "#{ab_test_campaign_goal} message #{message}"
      VWO::Logger.class_variable_get('@@logger_instance').log(level, message)
    end
  end
end

def stop_logger
  VWO::Logger.class_eval do
    def log(level, message)
      message = "#{Time.now} #{message}"
      VWO::Logger.class_variable_get('@@logger_instance').log(level, message)
    end
  end
end

get '/' do
  haml :index
end

get '/basic_example' do
  # matches "GET /basic_example?ab_campaign_key=#{ab_test_campaign_key}&userId=King&ab_campaign_goal_identifier=#{ab_test_campaign_goal}&revenue=10"
  ab_campaign_key = params['ab_campaign_key']
  user_id = params['userId'] || USERS.sample
  revenue_value = params['revenue'].to_i
  ab_campaign_goal_identifier = params['ab_campaign_goal_identifier']

  variation_name = $vwo_client_instance.activate(ab_campaign_key, user_id)
  $vwo_client_instance.track(ab_campaign_key, user_id, ab_campaign_goal_identifier, revenue_value)

  erb :template, locals: {
    part_of_campaign: variation_name.nil? ? 'No' : 'Yes',
    variation_name: variation_name,
    settings_file: $vwo_client_instance.get_settings,
    ab_campaign_key: ab_campaign_key,
    ab_campaign_goal_identifier: ab_campaign_goal_identifier,
    user_id: user_id
  }
end

get '/logger' do
  # matches "GET /logger?ab_campaign_key=#{ab_test_campaign_key}&userId=King&ab_campaign_goal_identifier=#{ab_test_campaign_goal}&revenue=10"
  start_logger
  ab_campaign_key = params['ab_campaign_key']
  user_id = params['userId'] || USERS.sample
  revenue_value = params['revenue'] ? params['revenue'].to_i : nil
  ab_campaign_goal_identifier = params['ab_campaign_goal_identifier']

  variation_name = $vwo_client_instance.activate(ab_campaign_key, user_id)
  $vwo_client_instance.track(ab_campaign_key, user_id, ab_campaign_goal_identifier, revenue_value)

  stop_logger
  erb :template, locals: {
    part_of_campaign: variation_name.nil? ? 'No' : 'Yes',
    variation_name: variation_name,
    settings_file: $vwo_client_instance.get_settings,
    ab_campaign_key: ab_campaign_key,
    ab_campaign_goal_identifier: ab_campaign_goal_identifier,
    user_id: user_id
  }
end

get '/user_storage' do
  # matches "GET /user_storage?ab_campaign_key=#{ab_test_campaign_key}&userId=King&ab_campaign_goal_identifier=#{ab_test_campaign_goal}&revenue=10"
  ab_campaign_key = params['ab_campaign_key']
  user_id = params['userId'] || USERS.sample
  revenue_value = params['revenue'].to_i
  ab_campaign_goal_identifier = params['ab_campaign_goal_identifier']

  variation_name = $vwo_client_instance_user_storage.activate(ab_campaign_key, user_id)
  $vwo_client_instance_user_storage.track(ab_campaign_key, user_id, ab_campaign_goal_identifier, revenue_value)

  erb :template, locals: {
    part_of_campaign: variation_name.nil? ? 'No' : 'Yes',
    variation_name: variation_name,
    settings_file: $vwo_client_instance_user_storage.get_settings,
    ab_campaign_key: ab_campaign_key,
    ab_campaign_goal_identifier: ab_campaign_goal_identifier,
    user_id: user_id
  }
end

__END__

@@ index
%div Examples Available
%a{href: "/basic_example?ab_campaign_key=#{ab_test_campaign_key}&ab_campaign_goal_identifier=#{ab_test_campaign_goal}&revenue=10"} Basic App Example
%a{href: "/logger?ab_campaign_key=#{ab_test_campaign_key}&ab_campaign_goal_identifier=#{ab_test_campaign_goal}&revenue=10"} User Defined Logger Example
%a{href: "/user_storage?ab_campaign_key=#{ab_test_campaign_key}&ab_campaign_goal_identifier=#{ab_test_campaign_goal}&revenue=10"} User Storage Example
