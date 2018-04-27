# Definitions
build_path = build
build_tool = runtime-container.DONE
#git_commit ?= $(shell git log --pretty=oneline -n 1 -- ../gatk4 ../spark-and-maven | cut -f1 -d " ")
name = bmwlee/usyd_runenv
tag = 0.4

# Steps
build: ${build_tool}

${build_tool}: build/Dockerfile
	cd build && docker build -t ${name}:${tag} .
	docker tag ${name}:${tag} ${name}:latest
	touch ${build_tool}

clean:
	-rm ${build_tool}
	docker rmi -f ${name}:${tag}
	docker rmi -f ${name}:latest
#
#test: build
#
push:
	docker push ${name}:${tag}
	docker push ${name}:latest

