OS=$(shell uname -s)
CPU=$(shell uname -m)

ifeq ($(CPU),i686)
	CPU=i386
endif

ifeq ($(CPU),i386)
	CFLAGS=-m32
	LDFLAGS=-m32
else
	CFLAGS=-m64
	LDFLAGS=-m64
endif

ifeq ($(OS),Darwin)
	target=libjpcre-osx-$(CPU).dylib
	CFLAGS+= -I/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers/
else ifeq ($(OS),Linux)
	target=libjpcre-linux-$(CPU).so
	CFLAGS+= -I${JAVA_HOME}/include -I${JAVA_HOME}/include/linux
endif


all: $(target) target/JPcre.jar

jpcre_wrap.c: jpcre.i
	swig -java -package jpcre -outdir jpcre jpcre.i

jpcre.o: jpcre.c jpcre.h
	gcc $(CFLAGS) -c jpcre.c

jpcre_wrap.o: jpcre_wrap.c
	gcc $(CFLAGS) -c jpcre_wrap.c

libjpcre-osx-$(CPU).dylib: jpcre.o jpcre_wrap.o
	gcc $(LDFLAGS) -dynamiclib -Wl,-headerpad_max_install_names,-undefined,dynamic_lookup,-compatibility_version,1.0,-current_version,1.0,-install_name,/usr/local/lib/$(target) -lpcre -o $(target) jpcre.o jpcre_wrap.o 

libjpcre-linux-$(CPU).so: jpcre.o jpcre_wrap.o
	gcc $(LDFLAGS) -shared -lpcre -o $(target) jpcre.o jpcre_wrap.o

target:
	mkdir -p target

target/jpcre/JPcre.class: target jpcre/JPcre.java
	javac -d target jpcre/JPcre.java

target/jpcre/RawJPcre.class: target jpcre/RawJPcre.java
	javac -d target jpcre/RawJPcre.java

target/jpcre/RawJPcreJNI.class: target jpcre/RawJPcreJNI.java
	javac -d target jpcre/RawJPcreJNI.java

target/JPcre.jar: $(target) target/jpcre/JPcre.class target/jpcre/RawJPcre.class target/jpcre/RawJPcreJNI.class
	jar cf target/JPcre.jar -C target jpcre $(target)

test.class: test.java target/JPcre.jar
	javac -cp target/JPcre.jar test.java

test: test.class
	java -cp target/JPcre.jar:. test "/^.(.)./i" "bob"

clean:
	rm -rf jpcre/RawJPcre* target *.class *.o *.dylib jpcre_wrap.c
