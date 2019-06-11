# yubihsm-connector

DIR := ${CURDIR}

MAKEFLAGS += -s
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

all: build

gen:
	go generate -mod=vendor ./...

build: gen
	go build -mod=vendor -o bin/yubihsm-connector ./...
build:
	CGO_CFLAGS="-I/opt/local/include" CGO_LDFLAGS="-L/opt/local/lib" go build -mod=vendor -o bin/yubihsm-connector ./...
#	cd src/yubihsm-connector && CGO_CFLAGS="-I/opt/local/include" CGO_LDFLAGS="-L/opt/local/lib" GOPATH="${GOPATH}:${DIR}/vendor" go build && cp yubihsm-connector ../../bin && cd ../..

rebuild: clean build

install: build
	install bin/yubihsm-connector /usr/local/bin

update:
	gb vendor update --all

cert:
	./tools/generate-certificate

run: build
	./bin/yubihsm-connector -d

srun: cert build
	./bin/yubihsm-connector -d --cert=var/cert.crt --key=var/cert.key

fmt:
	go fmt ./src/...

vet: gen
	go vet ./src/...

test: vet
	go test -v ./...

utest:
	echo "PWD=${DIR}"

docker-clean:
	docker rmi yubico/yubihsm-connector

docker-build:
	@docker build -t yubico/yubihsm-connector -f Dockerfile .

docker-run:
	@docker run --rm -it --privileged -v ${PWD}:/yubihsm-connector -v /dev/bus/usb/:/dev/bus/usb/ -p 12345:12345 yubico/yubihsm-connector

clean:
	rm -rf pkg/* src/yubihsm-connector/*.syso \
		src/yubihsm-connector/versioninfo.json \
		src/yubihsm-connector/version.go

.PHONY: all build fmt vet test clean version
