


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
            ((1/(dy*dy))*(thrust::get<1>(t)-2*thrust::get<0>(t)+thrust::get<4>(t))+
            (1/(dx*dx))*(thrust::get<2>(t)-2*thrust::get<0>(t)+thrust::get<3>(t))); 
        }
    }
};

struct temperature_update_functor2{

private:
    double dx, dy, dt, alpha;

public:
    temperature_update_functor2(double _dx, double _dy,
        double _dt, double _alpha) : dx(_dx), dy(_dy), dt(_dt), alpha(_alpha){}

    template <typename Tuple>
    __host__ __device__
    void operator() (Tuple t){
        if(thrust::get<3>(t)){
            thrust::get<0>(t) +=
            (alpha*dt)*
            ((1/dx*dx)*
                (thrust::get<0>(thrust::get<1>(t)) + thrust::get<1>(thrust::get<1>(t)))+
             (1/dy*dy)*
                (thrust::get<0>(thrust::get<2>(t)) + thrust::get<1>(thrust::get<2>(t))));
        }
    }
};