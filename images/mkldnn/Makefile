.PHONY: build deploy pull

build:
	docker build --network=host --rm -t dnnl:stable .

run:
	docker run --cap-add SYS_ADMIN -it dnnl:stable /bin/bash
