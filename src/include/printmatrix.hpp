# include <iostream>
# include <iomanip>
# include <fstream>

# define TO1D(x, y, ncols) (((x)*(ncols)) + (y))

template <typename Type>
void printmatrix (Type& A, int N_i, int N_j){
    for(int i=0; i<N_i; i++){
        std::cout << std::endl;
        for(int j=0; j<N_j; j++){
            int idx = TO1D(i, j, N_j);
            std::cout << std::setw(8) << A[idx];
        }
    }
    std::cout << std::endl;
} 

template <typename T>
void write_to_file(T* ary, int m, int n){
    int i, j;
    int ix;
    std::ofstream output("../results/output.txt");
    for(i=0; i<m; i++){
        for(j=0; j<n; j++){
            ix = TO1D(i, j, n);
            output << ary[ix] << ", ";
        }
    output << std::endl;
    }
}