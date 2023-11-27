#!/bin/sh 

alias pg='psql postgres://postgres:postgres@localhost:5432/postgres'
alias curl='curl -s'

exec > ./results.out 2>&1

echo 'step 0 - drop all queue definitions' 

pg -c 'delete from queue_definitions cascade'; 

echo 'step 1.1 - create queue'

curl --request POST \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '{ "ident": "spiders" }' \
  http://localhost:8080/v1/queues | jshon -Q 

echo ''
echo ''

# 

echo 'step 1.2 - fetch feeds' 

curl -X GET http://localhost:8081/feed/rss/me/spiders
echo ''
echo ''
curl -X GET http://localhost:8081/feed/atom/me/spiders
echo ''
echo ''
curl -X GET http://localhost:8081/feed/json/me/spiders | jshon -Q 
echo ''
echo ''

# 

echo 'step 2.1 - setup auth'

curl --request PUT \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '{ "isRequired": "true" }' \
  http://localhost:8080/v1/queues/spiders/auth | jshon -Q 

echo ''
echo ''

# 

echo 'step 2.2 - setup credentials'

curl --request POST \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '{ "basicUsername": "username", "basicPassword": "password" }' \
  http://localhost:8080/v1/queues/spiders/credentials | jshon -Q 

echo ''
echo '' 

# 

echo 'step 3.1 - create post'

CREATE_POST_RESPONSE=`curl --request POST \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '[{ "postTitle": { "value": "spiders article" }, "postDesc": { "value": "spiders article description" } }]' \
  http://localhost:8080/v1/queues/spiders/posts`

echo ${CREATE_POST_RESPONSE} | jshon -Q 
echo ''
echo ''

POST_ID="`echo ${CREATE_POST_RESPONSE} | jshon -e postIds -e 0 -u`"

# 

echo 'step 3.2 - update post status to PUB_PENDING'

curl --request PUT \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '{ "newStatus": "PUB_PENDING" }' \
  http://localhost:8080/v1/posts/${POST_ID}/status | jshon -Q 

echo ''
echo '' 

#

echo 'step 3.3 - deploy queue'

curl --request PUT \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '"DEPLOY_PENDING"' \
  http://localhost:8080/v1/queues/spiders/status | jshon -Q 

echo ''
echo '' 

# 

echo 'step 3.4 - fetch feeds'

curl -u username:password -X GET http://localhost:8081/feed/rss/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/atom/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/json/me/spiders | jshon -Q 
echo ''
echo ''

# 

echo 'step 4.1 - add a podcast descriptor' 

curl --request PUT \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '{
    "author": "me",
    "duration": 3600000,
    "episode": 1,
    "episodeType": "FULL",
    "imageUri": "http://localhost:666/img/spiders",
    "isBlock": false,
    "isCloseCaptioned": false,
    "isExplicit": true,
    "keywords":
    [
        "spiders"
    ],
    "order": 1,
    "season": 1,
    "subTitle": "8-legged foes",
    "summary": "Spiders rum amok",
    "title": "Spiders on the loose"
  }' \
  http://localhost:8080/v1/posts/${POST_ID}/itunes | jshon -Q 

echo ''
echo '' 

# 

echo 'step 4.2 - add an enclosure' 

curl --request POST \
  -H "Content-Type: application/json" \
  -H "X-ComposableRSS-API-Key: ${API_KEY}" \
  -H "X-ComposableRSS-API-Secret: ${API_SECRET}" \
  --data '{ 
    "url": "http://localhost:666/assets/spiders.mp4",
    "type": "MPEG-4",
    "length": "1048567"
  }' \
  http://localhost:8080/v1/posts/${POST_ID}/enclosures | jshon -Q 

echo ''
echo ''

# 

echo 'step 4.3 - fetch feeds' 

curl -u username:password -X GET http://localhost:8081/feed/rss/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/atom/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/json/me/spiders | jshon -Q 

# 

echo 'step 5.1 - add post media'

curl --request PUT   -H "Content-Type: application/json"   -H "X-ComposableRSS-API-Key: ${API_KEY}"   -H "X-ComposableRSS-API-Secret: ${API_SECRET}"   --data '{ "postMediaGroups": [ { "postMediaContents": [ { "height": "1024", "reference": { "uri": "https://localhost:666/video.mpg" }, "type": "MPEG-4", "width": "1024" } ], "postMediaMetadata": { "title": "All About Spiders", "thumbnails": [ ], "desc": "A video all about spiders", "community": { "starRating": { "average": "5", "count": "1024", "max": "5", "min": "5" }, "statistics": { "favorites": "1024", "views": "1024" } } } } ] }' http://localhost:8080/v1/posts/${POST_ID}/media

echo ''
echo ''

echo 'step 5.2 - fetch feeds' 

curl -u username:password -X GET http://localhost:8081/feed/rss/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/atom/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/json/me/spiders | jshon -Q 

echo '' 
echo '' 

echo 'setup 6 - configure advanced options' 

curl --request PUT   -H "Content-Type: application/json"   -H "X-ComposableRSS-API-Key: ${API_KEY}"   -H "X-ComposableRSS-API-Secret: ${API_SECRET}"   --data '{ "atomConfig": { "authorEmail": "me@localhost", "authorName": "meh", "authorUri": "https://www.lostsidewalk.com", "categoryLabel": "Spiders", "categoryTerm": "spiders" }, "rssConfig": { "categoryValue": "spiders", "docs": "https://www.rssboard.org/rss-specification", "managingEditor": "meh@lostsidewalk.com (meh)", "rating": "GA", "skipDays": "Monday,Tuesday", "skipHours": "0,1,2","ttl": 60, "webMaster": "meh@lostsidewalk.com (meh)" } }' http://localhost:8080/v1/queues/spiders/options

echo ''
echo ''

echo 'step 6.1 - fetch feeds' 

curl -u username:password -X GET http://localhost:8081/feed/rss/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/atom/me/spiders
echo ''
echo ''
curl -u username:password -X GET http://localhost:8081/feed/json/me/spiders | jshon -Q 

echo '' 
echo '' 

sed -i 's/\r$//' ./results.out 
