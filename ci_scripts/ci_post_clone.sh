#!/bin/zsh

#  ci_post_clone.sh
#  Boostz
#
#  Created by Thomas Rademaker on 1/9/24.
#  

development_team_value=$DEVELOPMENT_TEAM
bundle_id_prefix_value=$BUNDLE_ID_PREFIX
PODCAST_INDEX_API_KEY=$PODCAST_INDEX_API_KEY
PODCAST_INDEX_API_SECRET=$PODCAST_INDEX_API_SECRET
PODCAST_INDEX_USER_AGENT=$PODCAST_INDEX_USER_AGENT

config_file_path="../User.xcconfig"

# Check for the presence of 'user.xcconfig'
if [ -f "$config_file_path" ]; then
echo "User.xcconfig exists."
else
echo "Creating User.xcconfig and populating it with environment variables"
echo "DEVELOPMENT_TEAM = $development_team_value" > "$config_file_path"
echo "BUNDLE_ID_PREFIX = $bundle_id_prefix_value" >> "$config_file_path"
echo "PODCAST_INDEX_API_KEY = $podcast_index_api_key_value" >> "$config_file_path"
echo "PODCAST_INDEX_API_SECRET = $podcast_index_api_secret_value" >> "$config_file_path"
echo "PODCAST_INDEX_USER_AGENT = $podcast_index_user_agent_value" >> "$config_file_path"
fi
