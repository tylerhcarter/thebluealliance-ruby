# The Blue Alliance: Ruby

Simple ruby implementation of The Blue Alliance FRC API.

## Installation

Install this gem as you would any other.

If you are running bash, you can type
`gem install thebluealliance`

## Use

To be able to run all the commands you must first create an API object.
``` ruby
require 'thebluealliance'

# The fields are only used for access logging
api = TBA_API.new('orginization', 'app_id', 'version')
```

Now that you can run any command using the object, and access the results as a hash object.

```ruby

team = api.get_team('frc2202')

puts team['nickname']
# Displays: Beast Robotics
```

For more information on TheBlueAlliance api check the [Documentation](https://www.thebluealliance.com/apidocs)
