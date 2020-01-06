require 'sinatra'
require 'vwo'
require 'haml'
require "json"
require 'time'
require 'erb'
require_relative 'user_storage'
require_relative 'constants'
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
  erb :home
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

get '/ab' do
  user_id = params['userId'] || USERS.sample
  variation_name = $vwo_client_instance_user_storage.activate(AbCampaignData['campaign_key'], user_id, { custom_variables: AbCampaignData['custom_variables'] })
  is_part_of_campaign = !variation_name.nil?
  $vwo_client_instance_user_storage.track(AbCampaignData['campaign_key'], user_id, AbCampaignData['campaign_goal_identifier'], { revenue_value: AbCampaignData['revenue_value'] })
  
  erb :ab, locals: {
    user_id: user_id,
    campaign_type: "Visual-AB",
    is_part_of_campaign: is_part_of_campaign,
    variation_name: variation_name,
    ab_campaign_key: AbCampaignData['campaign_key'],
    ab_campaign_goal_identifier: AbCampaignData['campaign_goal_identifier'],
    custom_variables: JSON.generate(AbCampaignData['custom_variables']),
    settings_file: $vwo_client_instance_user_storage.get_settings
  }
end

get '/feature-rollout' do
  user_id = params['userId'] || FeatureRolloutData['user_id'] || USERS.sample
  is_user_part_of_feature_rollout_campaign = $vwo_client_instance.feature_enabled?(FeatureRolloutData['campaign_key'], user_id, { custom_variables: FeatureRolloutData['custom_variables'] })
  
  erb :feature_rollout, locals: {
    user_id: user_id,
    campaign_type: 'Feature-rollout',
    is_user_part_of_feature_rollout_campaign: is_user_part_of_feature_rollout_campaign,
    feature_rollout_campaign_key: FeatureRolloutData['campaign_key'],
    custom_variables: JSON.generate(FeatureRolloutData['custom_variables']),
    settings_file: $vwo_client_instance.get_settings
  }
end

get '/feature-test' do
  user_id = params['userId'] || FeatureTestData['user_id'] || USERS.sample
  is_user_part_of_feature_campaign = $vwo_client_instance.feature_enabled?(FeatureTestData['campaign_key'], user_id)
  $vwo_client_instance.track(
    FeatureTestData['campaign_key'],
    user_id,
    FeatureTestData['campaign_goal_identifier'],
    revenue_value=FeatureTestData['revenue_value'],
    custom_variables=FeatureTestData['custom_variables']
  )
  string_variable = $vwo_client_instance.get_feature_variable_value(FeatureTestData['campaign_key'], FeatureTestData['string_variable_key'], user_id, { custom_variables: FeatureTestData['custom_variables'] })
  integer_variable = $vwo_client_instance.get_feature_variable_value(FeatureTestData['campaign_key'], FeatureTestData['integer_variable_key'], user_id, { custom_variables: FeatureTestData['custom_variables'] })
  boolean_variable = $vwo_client_instance.get_feature_variable_value(FeatureTestData['campaign_key'], FeatureTestData['boolean_variable_key'], user_id, { custom_variables: FeatureTestData['custom_variables'] })
  double_variable = $vwo_client_instance.get_feature_variable_value(FeatureTestData['campaign_key'], FeatureTestData['double_variable_key'], user_id, { custom_variables: FeatureTestData['custom_variables'] })
  
  erb :feature_test, locals: {
    user_id: user_id,
    campaign_type: "Feature-test",
    is_user_part_of_feature_campaign: is_user_part_of_feature_campaign,
    feature_campaign_key: FeatureTestData['campaign_key'],
    feature_campaign_goal_identifier:  FeatureTestData['campaign_goal_identifier'],
    string_variable: string_variable,
    integer_variable: integer_variable,
    boolean_variable: boolean_variable,
    double_variable: double_variable,
    custom_variables: JSON.generate(FeatureRolloutData['custom_variables']),
    settings_file: $vwo_client_instance.get_settings
  }
end

get '/push' do
  user_id = params['userId'] || USERS.sample
  result = $vwo_client_instance.push(PushData['tag_key'], PushData['tag_value'], user_id)
  
  erb :push, locals: {
    user_id: user_id,
    tag_key: PushData['tag_key'],
    tag_value: PushData['tag_value'],
    result: result,
    settings_file: $vwo_client_instance.get_settings
  }
end
