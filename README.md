<link rel="stylesheet" type="text/css" href="style.css">

# ComposableRSS

ComposableRSS is a multiuser platform for creating, publishing, and fully managing all aspects of the syndicated web feed lifecycle. It provides a robust solution for managing web feeds and content distribution using a developer-friendly REST API. ComposableRSS is built upon the GPLV3 NewsGears libraries, implemented entirely in Java, and is freely available on Github.

## Features 

- Syndicated feed server supporting RSS, ATOM, and JSON formats 
- REST API for creating feeds and content, and managing the entire feed lifecycle 
- Supports publishing web feeds in RSS, ATOM, and JSON formats 
- Supports feed authentication using HTTP BASIC with unlimited number of users 
- Supports publishing iTunes podcast feeds  
- Supports publishing MediaRSS feeds (i.e., Youtube channels) 
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
- 8080 API server 
- 8081 feed server 
- 8082 engine
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

## 2. Using the API:

When authentication is required, the ComposableRSS API requires two header values to be present in each request:

```
X-ComposableRSS-API-Key API Key
X-ComposableRSS-API-Secret API Secret
```

Assuming `API_KEY` and `API_SECRET` are properly defined environment variables, you can query the ComposableRSS API using cURL as follows:

```
curl -H "X-ComposableRSS-API-Key ${API_KEY}" -H "X-ComposableRSS-API-Secret ${API_SECRET}" http://localhost:8080/[endpoint]
```

### Create and publish a feed 

To publish your first web feed, start by creating a *post queue*. A post queue is a container for articles.  In RSS, a queue is ultimately represented by a *channel*, while posts are *items*; in ATOM, a queue is a *feed*, and posts and *entries*.  The only required field in the request is 'ident,' a short unique identifier for the queue. Let's name our queue 'spiders' 🕷️, which will contain articles (posts) about spiders 🕷️:

```
curl --request POST \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '{ "ident": "spiders" }' \
  http://localhost:8080/v1/queues
```

The response payload will look like this:

```
{
  "deployResponses":
  {
    "ATOM_10":
    {
      "publisherIdent": "ATOM_10",
      "timestamp": "2023-11-08T15:23:29.132+00:00",
      "urls":
      [
        "http://localhost:8081/feed/atom/c9e99583-62b2-4acc-aff7-cefc6c911e9b",
        "http://localhost:8081/feed/atom/me/spiders"
      ]
    },
    "JSON":
    {
      "publisherIdent": "JSON",
      "timestamp": "2023-11-08T15:23:29.146+00:00",
      "urls":
      [
        "http://localhost:8081/feed/json/c9e99583-62b2-4acc-aff7-cefc6c911e9b",
        "http://localhost:8081/feed/json/me/spiders"
      ]
    },
    "RSS_20":
    {
      "publisherIdent": "RSS_20",
      "timestamp": "2023-11-08T15:23:29.132+00:00",
      "urls":
      [
        "http://localhost:8081/feed/rss/c9e99583-62b2-4acc-aff7-cefc6c911e9b",
        "http://localhost:8081/feed/rss/me/spiders"
      ]
    }
  },
  "queueDTO":
  {
    "ident": "spiders",
    "isAuthenticated": false,
    "language": "en-US",
    "transportIdent": "c9e99583-62b2-4acc-aff7-cefc6c911e9b"
  }
}
```

The HTTP 201 (CREATED) response status code indicates that the queue was successfully created. The body of the response provides the URLs of the associated feeds organized by format (the deployResponses section), and the properties of the newly created queue (the queueDTO section). ComposableRSS will respond with this information any time you create or change a queue.

Following each feed URL, we can see that our queue is delivered in the requested format by the feed server:

```
curl -X GET http://localhost:8081/feed/rss/me/spiders

<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>spiders</title>
    <link>http://localhost:8081/feed/rss/c9e99583-62b2-4acc-aff7-cefc6c911e9b</link>
    <description>spiders</description>
    <language>en-US</language>
    <pubDate>Wed, 08 Nov 2023 15:23:29 GMT</pubDate>
    <generator>NewsGears RSS</generator>
    <ttl>10</ttl>
  </channel>
</rss>
```

```
curl -X GET http://localhost:8081/feed/atom/me/spiders

<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>spiders</title>
  <link rel="self" href="http://localhost:8081/feed/atom/c9e99583-62b2-4acc-aff7-cefc6c911e9b" />
  <subtitle type="text">spiders</subtitle>
  <id>http://localhost:8081/feed/atom/c9e99583-62b2-4acc-aff7-cefc6c911e9b</id>
  <generator uri="https://www.feedgears.com" version="0.5.9">NewsGears RSS</generator>
</feed>
```

```
curl -X GET http://localhost:8081/feed/json/me/spiders

{
  "feed":
  {
    "ident": "spiders",
    "language": "en-US",
    "pubDate": "Nov 8, 2023, 3:23:29 PM",
    "url": "http://localhost:8081/feed/json/c9e99583-62b2-4acc-aff7-cefc6c911e9b"
  },
  "posts":
  []
}
```

Our 'spiders' 🕷️ feed is currently missing any items/entries since our newly created queue doesn't have any posts yet. Adding posts will be the next step after exploring how to set up authentication, an optional step for securing access to your feeds.

Further API documentation is available in the client UI, which you can reach at [http://localhost:3000](http://localhost:3000).

## 3. For local development: 

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

This script should be run from the top-level project directory (`composable-rss-app`).  

### build_client.sh: 

The client module image is assembled with `build_client.sh`: 

```
buid_client.sh
```

The provided `headless` docker-compose files exclude the client module, so that you can run it in an IDE (vscode suggested), using `npm run dev -o --` (or similar).   

This script should be run from the top-level project directory (`composable-rss-app`).  

## 4. Screenshot 

![screenshot_121923](https://github.com/lostsidewalk/composable-rss-app/assets/75078721/b005fb08-3ada-473a-8e29-ae06ca293482)

# Copyright and License

This project is licensed under the terms of the GNU General Public License, version 3 (GPLv3).

## Copyright

Copyright (c) 2023 Lost Sidewalk Software LLC

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).
