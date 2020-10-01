OWNER := ikyriakidis
IMAGE_NAME := mssql-server-windows-developer-2019
IMAGE_TAG := latest

IMAGE := $(OWNER)/$(IMAGE_NAME):$(IMAGE_TAG)

install:
	docker build --tag $(IMAGE) .

run:
	docker run --publish 1433:1433 --name database --detach $(IMAGE)

test: run
	@echo "Waiting for db to start..."
	n=60; \
	while [ $${n} -gt 0 ] ; do \
		echo '.' ; \
		sleep 1s ; \
		if [ $$(docker inspect --format '{{ .State.Health.Status }}' database 2> /dev/null | grep "healthy"  ) ]; then echo "Started!"; break ; fi;\
		n=`expr $$n - 1`; \
	done; \
	make -f Makefile clean

clean:
	docker stop database
	docker rm -v database

push:
	docker push $(IMAGE)

login:
	echo $${DockerHub_Token} | docker login --username $${DockerHub_User} --password-stdin
