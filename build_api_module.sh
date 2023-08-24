#!/bin/bash
#
# usage:
#
# FOR PROD BUILDS: ./build_api_module.sh --prod
#
# FOR LOCAL BUILDS: ./build_api_module.sh --local
#
CURRENT_DIR=$(basename `pwd`)
if [ ! "${CURRENT_DIR}" = "composable-rss-app" ]
then
	echo "Wrong dir: ${CURRENT_DIR}";
	exit;
fi
echo "Current dir: ${CURRENT_DIR}"

case $@ in
  "--prod")
    BUILD_ENV=prod
    ;;
  "--local")
    BUILD_ENV=local
    ;;
esac

if [ -z "${BUILD_ENV}" ]
then
  echo "No build environment";
  exit;
fi

MODULE_NAME=api;

. ./build-profiles/${MODULE_NAME}-${BUILD_ENV}.sh

echo "Building module: ${MODULE_NAME}, env: ${BUILD_ENV}, isDevelopment: ${isDevelopment}";

# change to the module dir
cd composable-rss-${MODULE_NAME}

# build the artifacts via gradle
./gradlew clean build

# build the docker image with the updated artifacts
docker build \
  --build-arg JAR_FILE=build/libs/*.jar \
  --build-arg AGENT_ARG=${agentArg} \
  --build-arg COMPRSS_DEVELOPMENT=${isDevelopment} \
  --build-arg COMPRSS_APPURL=${appUrl} \
  --build-arg COMPRSS_ORIGINURL=${originUrl} \
  --build-arg SPRING_DATASOURCE_URL=jdbc:postgresql://feedgears-db01:5432/postgres \
  --build-arg SPRING_DATASOURCE_USERNAME=postgres \
  --build-arg SPRING_DATASOURCE_PASSWORD=${datasourcePassword} \
  --build-arg SPRING_SQL_INIT_MODE=${sqlInitMode} \
  --build-arg SPRING_REDIS_HOST=feedgears-cache01 \
  --build-arg SPRING_REDIS_PASSWORD=${redisPassword} \
  --build-arg SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENTID=${googleClientId} \
  --build-arg SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_GOOGLE_CLIENTSECRET=${googleClientSecret} \
  --build-arg SPRING_MAIL_HOST=${mailHost} \
  --build-arg SPRING_MAIL_USERNAME=${mailUsername} \
  --build-arg SPRING_MAIL_PASSWORD=${mailPassword} \
  --build-arg TOKEN_SERVICE_SECRET=${tokenServiceSecret} \
  --build-arg STRIPE_SECRET_KEY=${stripeSecretKey} \
  --build-arg STRIPE_WH_SECRET_KEY=${stripeWhSecretKey} \
  --build-arg STRIPE_PRICE_ID=${stripePriceId} \
  -t composable-rss/composable-rss-${MODULE_NAME}:latest-${BUILD_ENV} \
  .

if [ "${BUILD_ENV}" = "prod" ]
then
	echo "Pushing Docker image to prod ECR...";
  docker tag composable-rss/composable-rss-${MODULE_NAME}:latest-prod 348965030247.dkr.ecr.us-east-2.amazonaws.com/composable-rss/composable-rss-${MODULE_NAME}:latest-prod
  docker push 348965030247.dkr.ecr.us-east-2.amazonaws.com/composable-rss/composable-rss-${MODULE_NAME}:latest-prod
fi

# return to parent dir (composable-rss-app)
cd ..