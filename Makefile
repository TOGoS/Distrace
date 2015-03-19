default: \
	run-mmap-test

run-mmap-test: mmap.d
	echo 'Hello, world!' >file.dat
	./mmap.d

%: %.d
	dmd "$<"

%.class: %.java
	javac "$<"
