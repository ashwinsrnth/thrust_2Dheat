# include <iostream>
# include <iomanip>

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