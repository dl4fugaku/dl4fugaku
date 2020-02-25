.PHONY: build deploy pull

build:
	docker build --network=host --rm -t torch_fugaku:stable .

run:
	docker run -it -p 8888:8888 -v $(shell pwd):/workdir/projects torch_fugaku:stable jupyter notebook --ip=0.0.0.0 --allow-root

interactive:
	docker run -it torch_fugaku:stable /bin/bash
#deploy:
#		docker push xxx

#pull:
#		docker pull xxx
