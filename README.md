## VWO Ruby SDK Example

This repository provides a basic demo of how server-side works with VWO Ruby SDK.

### Requirements

- ruby >= 1.9.3

### Documentation

Refer [VWO Official Server-side Documentation](https://developers.vwo.com/reference#fullstack-introduction)

### Setup

1. Install dependencies

```bash
# Assuming ruby is installed
gem install bundler (sudo if required)
bundle install
```

2. Update your app with your settings present in `config/vwo.json`

```json
"account_id": "REPLACE_THIS_WITH_CORRECT_VALUE"
"sdk_key": "REPLACE_THIS_WITH_CORRECT_VALUE"
"ab_campaign_key": "REPLACE_THIS_WITH_CORRECT_VALUE"
"ab_campaign_goal_identifeir": "REPLACE_THIS_WITH_CORRECT_VALUE"
```

3. Run application

```bash
ruby server.rb

# Hot Reloading app

gem install rerun (sudo if required)
rerun 'ruby server.rb'
```

## Basic usage

**Importing and Instantiation**

```ruby
require vwo_sdk

# Initialize client
vwo_client_instance = VWO.new(account_id, sdk_key)

# Get Settings
vwo_client_instance.get_settings

# Activate API
variation_name = vwo_client_instance.activate(campaign_test_key, user_id')

# GetVariation API
variation_name = vwo_client_instance.get_variation(campaign_test_key, user_id')

# Track API
vwo_client_instance.track(campaign_test_key, user_id', goal_identified, revenue_value)

```

**API usage**

**User Define Logger**


Override Existing Logging

```ruby
class VWO
  class Logger
    def initialize(logger_instance)
      # Only log info logs and above, no debug
      @@logger_instance = logger_instance || Logger.new(STDOUT, level: :info)
    end

    def log(level, message)
      # Basic Modification
      message = "#{Time.now} #{message}"
      @@logger_instance.log(level, message)
    end
  end
end
```

***Note*** - Make sure your custom logger instance has `log` method which takes `(level, message)` as arguments.

**User Storage**

To store a user you can override UserStorage methods. i.e -

```ruby
class VWO
  # Abstract class encapsulating user storage service functionality.
  # Override with your own implementation for storing
  # And retrieving the user storage.

  class UserStorage

    # Abstract method, must be defined to fetch the
    # User storage dict corresponding to the user_id.
    #
    # @param[String]        :user_id            ID for user whose storage needs to be retrieved.
    # @return[Hash]         :user_storage_obj   Object representing the user's storage.
    #
    def get(user_id)
      # example code to fetch it from DB column
      JSON.parse(User.find_by(vwo_id: user_id).vwo_user)
    end

    # Abstract method, must be to defined to save
    # The user storage dict sent to this method.
    # @param[Hash]    :user_storage_obj     Object representing the user's storage.
    #
    def set(user_storage_obj)
        # example code to save it in DB
        User.update_attributes(vwo_id: user_storage_obj.userId, vwo_user: JSON.generate(user_storage_obj))
    end
  end
end

# Now use it to initiate VWO client instance
vwo_client_instance = VWO.new(account_id, sdk_key, custom_logger, UserStorage.new)
```

### License

[Apache License, Version 2.0](https://github.com/wingify/vwo-ruby-sdk-example/blob/master/LICENSE)

Copyright 2019 Wingify Software Pvt. Ltd.
