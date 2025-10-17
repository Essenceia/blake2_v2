set PROJ "emulator"
set FILES [glob *.v ../*.v]

project new $PROJ
project set family Spartan3E
project set device xc3s100e
project set package cp132
project set speed -4

foreach f $FILES {
	xfile add $f
}
project set top $PROJ
