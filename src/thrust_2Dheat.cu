

/**
    thrust_2Dheat.cu
    ----------------

    Thrust based GPU solver for the 2-D heat equation, solved
    by explicit finite differences.

    This program runs the simulation. The 
    temperature_update_functor is defined here.
**/

#include <thrust/iterator/counting_iterator.h>
#include <thrust/iterator/transform_iterator.h>
#include <thrust/iterator/permutation_iterator.h>
#include <thrust/functional.h>
#include <thrust/iterator/zip_iterator.h>
#include <thrust/tuple.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/device_ptr.h>
#include <thrust/host_vector.h>

#include <stdlib.h>
#include <iomanip>
#include <typeinfo>
#include <time.h>
#include <stdio.h>

#include <tiled.h>
#include <init.h>
#include <functors.h>
#include <printmatrix.hpp>

int main(int argc, char* argv[]){

    double  L_x = 1024,
            L_y = 1024,
            N_x = 1024,
            N_y = 1024;

    // Read N_x, N_y from command line. If none provided
    // then taken from definition above.

    if (argc == 3){             // Override definitions for N_x, N_y
        N_x = atof(argv[1]);
        N_y = atof(argv[2]);
        L_x = N_x;
        L_y = N_y;
    }

    double  dx = (double)L_x/N_x,
            dy = (double)L_y/N_y,
            alpha = 0.02,
            dt = 1;

    int nsteps = 100;

    clock_t startclock, stopclock;
    double timeperstep;

    // Initialise temperatures in host memory (init.cu)
    thrust::host_vector<double> A_h(N_x*N_y);
    init_temp(thrust::raw_pointer_cast(A_h.data()), N_x, N_y);
    thrust::device_vector<double> A(A_h.begin(), A_h.end());

    // Create iterator for stencil which describes the boundaries (see README)
    thrust::device_vector<int> stencil(N_x, 1);
    stencil[0] = 0; stencil[N_x-1] = 0;

    typedef thrust::device_vector<int>::iterator IntIterator;
    typedef thrust::device_vector<double>::iterator DoubleIterator;
    typedef tiled_range<IntIterator> StencilIterator;
    typedef thrust::tuple<DoubleIterator, DoubleIterator, DoubleIterator, 
                          DoubleIterator, DoubleIterator, 
                          StencilIterator::iterator > IteratorTuple;
    
    typedef thrust::tuple<DoubleIterator, DoubleIterator> DoubleTuple;
    typedef thrust::zip_iterator<DoubleTuple> DoubleZipIterator;
    typedef thrust::tuple<DoubleIterator, DoubleZipIterator, DoubleZipIterator,
                          StencilIterator::iterator> StencilTuple;

    StencilIterator repeated_stencil(stencil.begin(), stencil.end(), N_y-1);

    // Temperature update loop:
    startclock = clock();
    
    for(int t=0; t<nsteps; t+=dt){
        DoubleIterator s1 = A.begin()+N_x;
        DoubleIterator s2 = A.begin()+N_x - N_x;
        DoubleIterator s3 = A.begin()+N_x - 1;
        DoubleIterator s4 = A.begin()+N_x + 1;
        DoubleIterator s5 = A.begin()+N_x + N_x;

        thrust::zip_iterator<StencilTuple> zip =
        make_zip_iterator(thrust::make_tuple(s1, 
                          thrust::make_zip_iterator(make_tuple(s3, s4)),
                          thrust::make_zip_iterator(make_tuple(s2, s5)),
                          repeated_stencil.begin()));

        thrust::for_each(zip, zip+N_y*N_x-2*N_x, 
                        temperature_update_functor2(dx, dy, dt, alpha));
        
    }
    stopclock = clock();
    
    // Calculate time per point per step:
    timeperstep =((double)(stopclock-startclock))/CLOCKS_PER_SEC;
    timeperstep = timeperstep / nsteps;
    timeperstep = timeperstep / (N_x*N_y);

    printf("Time per point per step = %e\n",timeperstep);
    
    // Copy results to host and write to file:
    A_h = A;
    write_to_file(A_h.data(), N_y, N_x);
    return 0;
}


