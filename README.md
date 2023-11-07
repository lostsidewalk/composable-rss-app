<link rel="stylesheet" type="text/css" href="style.css">

# composable-rss-app

composable-rss is a multi-user, self-hosted platform that allows you to programmatically create, publish, and manage syndicated web feeds.

The ComposableRSS platform is based on four container types, thus this repository contains four submodules:

composable-rss-api: provides HTTP-based REST access to the core syndicated web feed management capabilities of the entire platform

composable-rss-engine: performs scheduled/periodic tasks, such as expiring posts, re-deploying feeds, etc. 

composable-rss-client: a browser application that provides internal users a way to access documentation, manage API keys, and view metrics related to their feeds. 

newsgears-rss: a feed server that can serve syndicated web feeds (RSS, ATOM, others) to your (external) users.  

## To self-host ComposableRSS:

## 1. Setup docker-compose.yml:

Create a docker-compose.yml file from the same provided in this repository.

```
cp docker-compose.yml.sample docker-compose.yml 
```

#### (Optional) If you want to enable OAUTH2 via Google:
- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENTID=@null```
- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENTSECRET=@null```
- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_REDIRECTURI=http://localhost:8080/oauth2/callback/{registrationId}```
- ```SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_SCOPE=email,profile```

Get your own values for client Id/client secret from Google and plug them in to these variables in ```docker-compose.yml```.

The value of the OAuth2 redirect URI should be:

```
http://localhost:8080/oauth2/callback/{registrationId}
```

This is suitable for cases where your browser can reach ComposableRSS via localhost, port 8080, which should be the vast majority of cases.

The value of the ```scope``` property must be ```email,profile```, regardless of the OAuth2 provider.

If you don't want to use OAuth2, you'll have to go through the account registration process in order to login.

<hr>

## 2. Quick-start using pre-built containers:

If you don't want to do development, just start ComposableRSS using pre-built containers:

```
docker-compose up
```

<hr>

## 3. For local development:

If you don't want to use the pre-built containers (i.e., you want to make custom code changes and build your own containers), then use the following instructions.

### Setup command aliases:

A script called `build_module.sh` is provided to expedite image assembly.  Setup command aliases to run it to build the required images after you make code changes:

```
alias crss-api='./build_module.sh composable-rss-api'
alias crss-engine='./build_module.sh composable-rss-engine'
alias ng-rss='./build_module.sh newsgears-rss'
alias crss-client='./buid_client.sh'
```

#### Alternately, setup aliases build debuggable containers:

```
alias crss-api='./build_module.sh composable-rss-api --debug 45005'
alias crss-engine='./build_module.sh composable-rss-engine --debug 55005'
alias ng-rss='./build_module.sh newsgears-rss --debug 65005'
alias crss-client='./build_client.sh'
```

*Debuggable containers pause on startup until a remote debugger is attached on the specified port.*

### Build and run:

#### Run the following command in the directory that contains ```composable-rss-app```:

```
crss-api && crss-engine && ng-rss && crss-client && docker-compose up
```

Boot down in the regular way, by using ```docker-compose down``` in the ```composable-rss-app``` directory.

<hr> 

You can also use the `crss-api`, `crss-engine`, `ng-rss`, and `crss-client` aliases to rebuild the containers (i.e., to deploy code changes).

```
$ crss-api # rebuild the API server container 
$ crss-engine $ rebuild the engine server container 
$ ng-rss # rebuild the RSS server container 
$ crss-client # rebuild the client container 
```

Restart after each. 
