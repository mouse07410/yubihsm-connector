# yubihsm-connector

MAKEFLAGS += -s
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

all: build

build:
	gb generate ${GB_GEN_FLAGS}
	CGO_CFLAGS="-I/opt/local/include" CGO_LDFLAGS="-L/opt/local/lib" gb build ${GB_BUILD_FLAGS}

rebuild: clean build

install: build
	install bin/yubihsm-connector /usr/local/bin

cert:
	@./tools/generate-certificate

run: build
	@./bin/yubihsm-connector -d

srun: cert build
	@./bin/yubihsm-connector -d --cert=var/cert.crt --key=var/cert.key

fmt:
	@go fmt ./src/...

vet:
	@go vet ./src/...

test: vet
	@gb test ${GB_BUILD_FLAGS} -v

docker-clean:
	@docker rmi yubico/yubihsm-connector

docker-build:
	@docker build -t yubico/yubihsm-connector -f Dockerfile .

docker-run:
	@docker run --rm -it --privileged -v ${PWD}:/yubihsm-connector -v /dev/bus/usb/:/dev/bus/usb/ -p 12345:12345 yubico/yubihsm-connector

clean:
	@rm -rf bin/* pkg/* src/yubihsm-connector/*.syso \
		src/yubihsm-connector/versioninfo.json \
		src/yubihsm-connector/version.go

.PHONY: all build fmt vet test clean version
