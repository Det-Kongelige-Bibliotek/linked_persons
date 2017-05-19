#!/bin/bash
CONTAINER=$(pwd | xargs basename)_linked_persons_1
docker stop $CONTAINER
docker rm $CONTAINER
docker-compose build
docker-compose up -d
docker attach $CONTAINER
