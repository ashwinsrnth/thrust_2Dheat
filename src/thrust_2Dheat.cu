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

#include <iomanip>
#include <typeinfo>
#include <time.h>

#include <tiled.h>
#include <printmatrix.hpp>
#include <init.cu>

# define L_x 1
# define L_y 1
# define N_x 1024
# define N_y 1024

struct temperature_update_functor{

private:
    double dx, dy, dt, alpha;

public:
    temperature_update_functor(double _dx, double _dy, 
        double _dt, double _alpha) : dx(_dx), dy(_dy), dt(_dt), alpha(_alpha){}
     
    template <typename Tuple>
    __host__ __device__
    void operator() (Tuple t){  
        if(thrust::get<5>(t)){
            thrust::get<0>(t) += 
            (alpha*dt)*
            ((1/dy)*(thrust::get<1>(t)-2*thrust::get<0>(t)+thrust::get<4>(t))+
            (1/dx)*(thrust::get<2>(t)-2*thrust::get<0>(t)+thrust::get<3>(t))); 
        }
    }
};



int main(){

    double  dx = (double)L_x/N_x,
            dy = (double)L_y/N_y,
            alpha = 0.2,
            dt = 1;

    int nsteps = 10000;

    clock_t startclock, stopclock;
    double timeperstep;

    thrust::device_vector<double> A= init_temp(N_x, N_y);

    thrust::device_vector<int> stencil(N_x, 1);
    std::cout<<typeid(stencil).name()<<std::endl;
    stencil[0] = 0; stencil[N_x-1] = 0;

    // Create stencil iterators
    typedef thrust::device_vector<int>::iterator IntIterator;
    typedef thrust::device_vector<double>::iterator DoubleIterator;
    typedef tiled_range<IntIterator> StencilIterator;

    StencilIterator repeated_stencil(stencil.begin(), stencil.end(), N_x-1);

    startclock = clock();

    // Update temperatures 
    for(int t=0; t<nsteps; t+=dt){
        DoubleIterator s1 = A.begin()+N_y;
        DoubleIterator s2 = A.begin()+N_y - N_y;
        DoubleIterator s3 = A.begin()+N_y - 1;
        DoubleIterator s4 = A.begin()+N_y + 1;
        DoubleIterator s5 = A.begin()+N_y + N_y;

        typedef thrust::tuple<DoubleIterator, DoubleIterator, DoubleIterator, 
                              DoubleIterator, DoubleIterator, 
                              StencilIterator::iterator > IteratorTuple;
        
        thrust::zip_iterator<IteratorTuple> zip = 
        make_zip_iterator(thrust::make_tuple(s1, s2, s3, s4, s5, 
                                                repeated_stencil.begin()));

        thrust::for_each(zip, zip+N_y*N_x-2*N_x, 
                        temperature_update_functor(dx, dy, dt, alpha));
        
    }

    stopclock = clock();
    timeperstep =((double)(stopclock-startclock))/CLOCKS_PER_SEC;
    timeperstep = timeperstep / nsteps;
    timeperstep = timeperstep / (N_x*N_y);

    printf("Time per point per step = %e\n",timeperstep);


    thrust::host_vector<double> A_h = A;
    write_to_file(A_h.data(), N_y, N_x);

    return 0;
}


