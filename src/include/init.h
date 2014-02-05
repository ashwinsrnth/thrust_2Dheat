
thrust::device_vector<double> init_temp(double* temp1_h, int ni, int nj){

    /**
        Initial conditions for 2-D heat conduction problem. Dirichlet
        only.

        Parameters
        ----------

        int ni  -  Grid size in x- direction
        int nj  -  Grid size in y- direction

        Returns
        ----------

        thrust::device_vector of initial temperatures.

    */
   
    int i, j, i2d;
    double temp_bl, temp_br, temp_tl, temp_tr;

    // initial temperature in interior
    for (j=1; j < nj-1; j++) {
        for (i=1; i < ni-1; i++) {
            i2d = i + ni*j;
            temp1_h[i2d] = 0.0f;
        }
    }
    
    // initial temperature on boundaries - set corners
    temp_bl = 200.0f;
    temp_br = 300.0f;
    temp_tl = 200.0f;
    temp_tr = 300.0f;

    // set edges by linear interpolation from corners
    for (i=0; i < ni; i++) {
        // bottom
        j = 0;
        i2d = i + ni*j;
        temp1_h[i2d] = temp_bl + (temp_br-temp_bl)*(double)i/(double)(ni-1);

        // top
        j = nj-1;
        i2d = i + ni*j;
        temp1_h[i2d] = temp_tl + (temp_tr-temp_tl)*(double)i/(double)(ni-1);
    }

    for (j=0; j < nj; j++) {
        // left
        i = 0;
        i2d = i + ni*j;
        temp1_h[i2d] = temp_bl + (temp_tl-temp_bl)*(double)j/(double)(nj-1);

        // right
        i = ni-1;
        i2d = i + ni*j;
        temp1_h[i2d] = temp_br + (temp_tr-temp_br)*(double)j/(double)(nj-1);
    }

    thrust::device_vector<double> D(temp1_h, temp1_h + ni*nj);
    return D;
}
