AbCampaignData = {
  'campaign_key' => 'phpab3',
  'campaign_goal_identifier' => 'custom',
  'user_id' => nil,
  'revenue_value' => 10,
  # custom_variables => Optional param, used for pre-segmentation
  # 'custom_variables' => {}
}

FeatureRolloutData =  {
  'campaign_key' => 'php1',
  'user_id' => nil,
  # custom_variables => Optional param, used for pre-segmentation
  # 'custom_variables' => {}
}

FeatureTestData = {
  'campaign_key' => 'php4',
  'campaign_goal_identifier' => 'custom',
  'revenue_value' => '',
  'user_id' => nil,
  # custom_variables => Optional param, used for pre-segmentation
  'custom_variables' => {},
  'string_variable_key' => 'Test',
  'integer_variable_key' => '1',
  'double_variable_key' => '10.2',
  'boolean_variable_key' => 'true'
}

PushData = {
  'tag_key' => 'test',
  'tag_value' => 'value',
  'user_id' => nil,
}
