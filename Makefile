serve_local:
	hugo server -s hugo

build:
	mv -T public public-bak
	hugo -s hugo -d ../public

publish: build
	firebase deploy
