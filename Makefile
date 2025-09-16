all:
	make export
	make zip
	make upload

export:
	godot-4v4_1 --headless --export-release "Web" ./build/web/index.html

zip:
	zip -r build/web.zip build/web/

upload:
	butler push build/web.zip thisisrob/knots:web

clean:
	rm -rf build/*.zip build/*/*
