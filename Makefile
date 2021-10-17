REVISION := $(shell git rev-parse --short HEAD)

DATE = $(shell date "+%Y.%m.%d")
VERSION = ${DATE}-${REVISION}
DOCKER_IMAGE = cr.yandex/crpk28lsfu91rns28316/dockerlogtest
IMAGE_ID=$(shell yc compute image get-latest-from-family container-optimized-image --folder-id standard-images --format=json | jq -r .id)

docker_build:
	docker build -t $(DOCKER_IMAGE):$(VERSION) --file Dockerfile .


docker_push::
	docker push $(DOCKER_IMAGE):$(VERSION)

deploy::
	yc compute instance create \
    --name coi-vm \
    --zone=ru-central1-a \
    --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
    --metadata-from-file user-data=user-data.yaml,docker-compose=spec.yaml \
    --create-boot-disk image-id=$(IMAGE_ID) \
    --service-account-name apollo