.PHONY: build deploy pull

build:
	docker build --network=host --rm -t torch_fedora_custom_dnnl:stable .

run:
	docker run --cap-add SYS_ADMIN --cap-add SYS_PTRACE --security-opt seccomp=unconfined -it torch_fedora_custom_dnnl:stable /bin/bash
