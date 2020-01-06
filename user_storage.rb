class VWO
  # Abstract class encapsulating user storage functionality.
  # Override with your own implementation for storing
  # And retrieving the user.

  class UserStorage

    @@user_storage = {}

    # Abstract method, must be defined to fetch the
    # User Storage dict corresponding to the user_id.
    #
    # @param[String]        :user_id            ID for user whose storage needs to be retrieved.
    # @return[Hash]         :user_storage_obj   Object representing the user's storage.
    #
    def get(user_id, campaign_key = nil)
      # example code to fetch it from DB column
      @@user_storage[user_id]
    end

    # Abstract method, must be to defined to save
    # The user storage dict sent to this method.
    # @param[Hash]    :user_storage_obj     Object representing the user's storage.
    #
    def set(user_storage_obj)
      # example code to save it in DB
      @@user_storage[user_storage_obj['user_id']] = user_storage_obj
    end
  end
end
