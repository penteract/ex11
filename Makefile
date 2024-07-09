all:
	cd lib; make
	cd widgets; make

clean:
	cd lib; make clean
	cd widgets; make clean
