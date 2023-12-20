<link rel="stylesheet" type="text/css" href="style.css">

# ComposableRSS

ComposableRSS is a multi-user, self-hosted platform that allows you to programmatically create, publish, and manage syndicated web feeds.

## Features 

- Syndicated feed server supporting RSS, ATOM, and JSON formats 
- REST API for creating feeds and content, and managing the entire feed lifecycle 
- Supports RSS, ATOM, and JSON formats 
- Supports feed authentication
- Supports iTunes podcast feeds  
- Suppots MediaRSS feeds (i.e., Youtube channels) 
- OpenAPIv3 specification for easy integration/code generation  
- Scalable architecture can support thousands of concurrent users
- Free and self-hostable, get ComposableRSS up and running in seconds
- Built using free/open-source tools and libraries

The ComposableRSS platform is comprised of four main components, thus this repository contains four submodules:

**[composable-rss-api](https://github.com/lostsidewalk/composable-rss-api)**: provides HTTP-based REST access to the core syndicated web feed management capabilities of the entire platform

**[composable-rss-engine](https://github.com/lostsidewalk/composable-rss-engine)**: performs scheduled/periodic tasks, such as expiring posts, re-deploying feeds, etc. 

**[composable-rss-client](https://github.com/lostsidewalk/composable-rss-client)**: a browser application that provides internal users a way to access documentation, manage API keys, and view metrics related to their feeds. 

**[newsgears-rss](https://github.com/lostsidewalk/newsgears-rss)**: a feed server that can serve syndicated web feeds (RSS, ATOM, others) to your (external) users.  

## To self-host ComposableRSS:

## 1. Setup docker-compose.yml:

The easiest way to get started is to use one of the provided docker-compose files, by cloning this repository and creating a symlink, as follows: 

```
ln -s docker-compose.single-user.yml.sample docker-compose.yml
docker-compose up  
```

This is the simplest configuration, and will boot the app with the minimal number of containers necessary to run the app, and without authentication.  

The `multi-user` configurations will cause the app to require authentication to login, either via OAuth2 (which must also be configured, see below), or via local user account registration.  The `debug` and `headless` configurartions are for development purposes, see below. 

Note that you must have the following ports free on localhost: 
- 5432 postgres
- 6379 redis
- 8080 API
- 8082 engine
- 8083 broker
- 3000 front-end

Once the containers are fully booted, navigating to http://localhost:3000 will take you directly into the app.   

#### (Optional) If you want to enable OAUTH2 via Google:

If you use a multi-user docker-compose file, you will need to provide additional values in order to get OAUTH2 working: 

- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENTID=@null```
- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENTSECRET=@null```
- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_REDIRECTURI=http://localhost:8080/oauth2/callback/{registrationId}```
- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_SCOPE=email,profile```

Get your own values for client Id/client secret from Google and plug them in to these variables in ```docker-compose.yml```. 

The value of the OAuth2 redirect URI should be:

```
http://localhost:8080/oauth2/callback/{registrationId}
```

The value of the ```scope``` property must be ```email,profile```, regardless of the OAuth2 provider.

<hr>

## 2. For local development: 

I recommend using IntelliJ IDEA w/Lombok and Gradle support for developing the back-end components, and vscode for developing the front-end. See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.  

### build_module.sh: 

A script called `build_module.sh` is provided to expedite image assembly for composable-rss-api, composable-rss-engine, and newsgears-rss:  

```
build_module.sh composable-rss-api --debug 45005 
build_module.sh composable-rss-engine --debug 55005 
build_module.sh newsgears-rss --debug 65005
```

The `--debug <port>` parameter instructs the build script to configure the image runtime environment to pause the JVM until a debugger is connected on the specified port, and to tag the image with `latest-debug` instead of `latest-local`.  

The provided `docker-compose.single-user.debug.yml.sample` file uses the `latest-debug` images, and also exposes the necessary ports to reach your local debugger.  

### build_client.sh: 

The client module image is assembled with `build_client.sh`: 

```
buid_client.sh
```

The provided `headless` docker-compose files exclude the client module, so that you can run it in an IDE (vscode suggested), using `npm run devserve` (or similar).   

## Screenshot 

![screenshot_121923](https://github.com/lostsidewalk/composable-rss-app/assets/75078721/b005fb08-3ada-473a-8e29-ae06ca293482)

# Copyright and License

This project is licensed under the terms of the GNU General Public License, version 3 (GPLv3).

## Copyright

Copyright (c) 2023 Lost Sidewalk Software LLC

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).
