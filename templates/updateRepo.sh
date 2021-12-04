#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

notSetVars=""
for envVar in "PROJECT_NAME" "USER" "HOST" "PASSWORD" "DEST_FOLDER" "ORIGIN_FOLDER"; do
  if [[ -z "${!envVar+x}" ]]; then
    notSetVars="$notSetVars $envVar"
  fi
done
if [ ! -z "$notSetVars" ]; then
  echo "$notSetVars not set"
  exit 255
fi

cat << EOF > ${DEST_FOLDER}/Dockerfile
FROM node:lts

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app
COPY package-lock.json /usr/src/app
COPY public /usr/src/app/public
COPY ${ORIGIN_FOLDER} /usr/src/app/src
COPY server /usr/src/app/server


ENV NODE_ENV=production

RUN npm install --production

ENV VIRTUAL_HOST=${DOMAIN}
ENV LETSENCRYPT_HOST=${DOMAIN}
ENV LETSENCRYPT_EMAIL=${EMAIL}

EXPOSE 5000

CMD [ "npm", "run", "start:server" ]
EOF



#LC_PROJECT_NAME=${PROJECT_NAME}
#
#ssh -tt -o StrictHostKeyChecking=no "${USER}@${HOST}" <<< "mkdir -p Projects/${LC_PROJECT_NAME}; exit" && \
#rsync -rpulz --verbose "${PWD}/../*" "${USER}@${HOST}:./Projects/${LC_PROJECT_NAME}/." && \
#ssh -tt -o SendEnv=PROJECT_NAME -o StrictHostKeyChecking=no "${USER}@${HOST}" <<< "
#cd Projects/${LC_PROJECT_NAME}
#docker-compose up -d --build
#exit"
