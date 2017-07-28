#
# tcl library path for brew - needs to be parameterized somehow
#
# version for TCL brew package
TCLVERSION=8.6.6_2
BREWROOT=/usr/local/Cellar
#TCLLIBPATH=$(BREWROOT)/tcl-tk/$(TCLVERSION)/lib
TCLLIBPATH=/usr/lib
TCLINCPATH=$(BREWROOT)/tcl-tk/$(TCLVERSION)/include

BUILD=./.build

default: build

build: $(BUILD)

$(BUILD): Package.swift Makefile
	swift build -Xlinker -L$(TCLLIBPATH) -Xcc -I$(TCLINCPATH)

SwiftTcl.xcodeproj: Package.swift Makefile build
	swift package -Xlinker -L$(TCLLIBPATH) -Xlinker -ltcl8.6 -Xlinker -ltclstub8.6 generate-xcodeproj
	@echo "NOTE: You will need to manually set the working directory for the SwiftTclDemo scheme to the root directory of this tree."
	@echo "Thanks Apple"

# Brute force compile
libSwiftTcl.so: Sources/tcl.swift Sources/tcl-array.swift Sources/tcl-object.swift Sources/tcl-interp.swift
	mkdir -p .build/debug
	-swift build -Xswiftc -emit-library -Xswiftc -o -Xswiftc .build/debug/libSwiftTcl.so \
		-Xswiftc -Xlinker -Xswiftc -ltcl8.6 \
		-Xswiftc -Xlinker -Xswiftc -ltclrefcount8.6 \
		-Xswiftc -Xlinker -Xswiftc -ltclstub8.6 \
		-Xswiftc -Xlinker -Xswiftc -lz
	test -f libSwiftTcl.so

install: build
		cp .build/debug/libSwiftTcl.so /usr/lib/x86_64-linux-gnu
		ldconfig /usr/lib/x86_64-linux-gnu/libSwiftTcl.so

clean:
	rm -rf libSwiftTcl.so .build Package.pins

