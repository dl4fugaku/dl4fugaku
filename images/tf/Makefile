.PHONY: build deploy pull

build:
	docker build --rm -t dl4fugaku_tf:stable .

run:
	docker run -it -p 8888:8888 -v $(shell pwd):/workdir/projects dl4fugaku_tf:stable jupyter notebook --ip=0.0.0.0 --allow-root

interactive:
	docker run -it dl4fugaku_tf:stable /bin/bash
#deploy:
#		docker push xxx

#pull:
#		docker pull xxx