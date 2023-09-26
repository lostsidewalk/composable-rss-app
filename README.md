<link rel="stylesheet" type="text/css" href="style.css">

# composable-rss-app

composable-rss is a platform that allows you to programmatically create, publish, and manage syndicated web feeds.  

#### *What is a syndicated web feed?*


#### composable-rss works by combining the newsgears-rss feed server with a RESTful HTTP Application Programming Interface to provide endpoints for managing the entire lifecycle of  syndicated web feeds, in RSS 2.0, ATOM 1.0, and JSON formats.  

See [here](https://github.com/lostsidewalkllc/newsgears-app) for more information about the entire NewsGears platform (which also includes an aggregator and a web-based reader component), and see [here]() for more information about the NewsGears feed server component, which is a dependency of this program.    

This repository contains all material necessary to build the composable-rss-api server image, as well as the newsgears-rss feed server image, using instructions located [here]().  

A Docker composition is provided that can be used to start the containers locally (e.g., using <code>docker-compose up</code>), once built.
