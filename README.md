# PushrWns

[![Build Status](https://travis-ci.org/9to5/pushr-wns.svg?branch=master)](https://travis-ci.org/9to5/pushr-wns)
[![Code Climate](https://codeclimate.com/github/9to5/pushr-wns.png)](https://codeclimate.com/github/9to5/pushr-wns)
[![Coverage Status](https://coveralls.io/repos/9to5/pushr-wns/badge.png)](https://coveralls.io/r/9to5/pushr-wns)

Please see [pushr-core](https://github.com/9to5/pushr-core) for more information.

## Configuration

Redis:
```ruby
Pushr::ConfigurationWns.create(app: 'app_name', connections: 2, enabled: true, client_id: '<client_id>', client_secret: '<client_secret>)
```

YAML:
```yaml
- type: Pushr::ConfigurationWns
  app: wns-app
  enabled: true
  connections: 1
  client_id: client_id_here
  client_secret: client_secret_here
```

## Sending notifications

WNS:
```ruby
Pushr::MessageWns.create(
  app: 'test', channel_uri: 'https://db3.notify.windows.com/?token=token',
  data: '<toast launch=""><visual lang="en-US"><binding template="ToastImageAndText01"><image id="1" '\
        'src="World" /><text id="1">Hello</text></binding></visual></toast>',
  content_type: 'text/xml', x_wns_type: 'wns/toast')
```
