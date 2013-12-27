# Replace with Make variables

thrust_2Dheat : obj/thrust_2Dheat.o
	nvcc -o bin/thrust_2Dheat.bin obj/thrust_2Dheat.o

obj/thrust_2Dheat.o : src/thrust_2Dheat.cu
	nvcc -arch=sm_20 -o obj/thrust_2Dheat.o -I src/ -I src/include/ -c src/thrust_2Dheat.cu
