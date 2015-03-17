default: \
	write-read-floats

run-mmap: mmap.d
	echo 'Hello, world!' >file.dat
	./mmap.d

%: %.d
	dmd "$<"

%.class: %.java
	javac "$<"

write-read-floats: writefloat FloatReader.class
	./writefloat | java FloatReader 
