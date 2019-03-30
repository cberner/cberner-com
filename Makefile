serve_local:
	hugo server -s hugo

build:
	rm -rf public/
	hugo -s hugo -d ../public

publish: build
	firebase deploy
