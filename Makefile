

obj/thrust_2Dheat.o : src/thrust_2Dheat.cu
	nvcc -c src/thrust_2Dheat.cu -o obj/thrust_2Dheat.o -I src/ -I src/include/
