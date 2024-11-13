#include "stdlib.h"
#include "math.h"
#include "sys/time.h"
#include "stdio.h"

#include <cuda_runtime.h>
#include <device_launch_parameters.h>


#define _POSIX_C_SOURCE 200809L
#define START(S) struct timeval start_ ## S , end_ ## S ; gettimeofday(&start_ ## S , NULL);
#define STOP(S,T) gettimeofday(&end_ ## S, NULL); T->S += (double)(end_ ## S .tv_sec-start_ ## S.tv_sec)+(double)(end_ ## S .tv_usec-start_ ## S .tv_usec)/1000000;


#define dampL0_Host(x,y) damp[(x)*y_stride1 + (y)]
#define gradL0_Host(x,y) grad[(x)*y_stride2 + (y)]
#define recL0_Host(time,p_rec) rec[(p_rec) + (time)*p_rec_stride0]
#define rec_coordsL0_Host(p_rec,d) rec_coords[(d) + (p_rec)*d_stride0]
#define uL0_Host(time,x,y) u[(time)*x_stride0 + (x)*y_stride0 + (y)]
#define vL0_Host(t,x,y) v[(t)*x_stride0 + (x)*y_stride0 + (y)]
#define vpL0_Host(x,y) vp[(x)*y_stride1 + (y)]


#define dampL0(x,y) damp_dev[(x)*y_stride1 + (y)]
#define gradL0(x,y) grad_dev[(x)*y_stride2 + (y)]
#define recL0(time,p_rec) rec_dev[(p_rec) + (time)*p_rec_stride0]
#define rec_coordsL0(p_rec,d) rec_coords_dev[(d) + (p_rec)*d_stride0]
#define uL0(time,x,y) u_dev[(time)*x_stride0 + (x)*y_stride0 + (y)]
#define vL0(t,x,y) v_dev[(t)*x_stride0 + (x)*y_stride0 + (y)]
#define vpL0(x,y) vp_dev[(x)*y_stride1 + (y)]


struct dataobj
{
  void * __restrict__ data;
  unsigned long * size;
  unsigned long * npsize;
  unsigned long * dsize;
  long  * hsize;
  long  * hofs;
  long  * oofs;
  void * dmap;
} ;

struct profiler
{
  double section0=0.0;
  double section1=0.0;
  double section2=0.0;
} ;


#define NTHX 8
#define NTHY 16
#define NTH 128


__global__ void first_section(float *__restrict__ vp_dev, 
                              float *__restrict__ v_dev, 
                              float *__restrict__ damp_dev, 
                              const float r2, 
                              const float r1, 
                              const long  x_m, 
                              const long  x_M, 
                              const long  y_m, 
                              const long  y_M, 
                              const long  x_stride0, 
                              const long  y_stride0, 
                              const long  y_stride1,
                              const long  t0,
                              const long  t1,
                              const long  t2){

    long  x = x_m + blockIdx.x * blockDim.x + threadIdx.x;
    long  y = y_m + blockIdx.y * blockDim.y + threadIdx.y;


    if (x <= x_M && y <= y_M) {
        float r3 = 1.0F/(vpL0(x + 2, y + 2)*vpL0(x + 2, y + 2));

        vL0(t1, x + 4, y + 4) = (r3*(-(r1*(-2.0F*vL0(t0, x + 4, y + 4)) + r1*vL0(t2, x + 4, y + 4))) \
                              + r2*dampL0(x + 2, y + 2)*vL0(t0, x + 4, y + 4) \
                              + 8.33333315e-4F*(-vL0(t0, x + 2, y + 4) - vL0(t0, x + 4, y + 2) - vL0(t0, x + 4, y + 6) - vL0(t0, x + 6, y + 4)) \
                              + 1.3333333e-2F*(vL0(t0, x + 3, y + 4) + vL0(t0, x + 4, y + 3) + vL0(t0, x + 4, y + 5) + vL0(t0, x + 5, y + 4)) \
                              - 4.99999989e-2F*vL0(t0, x + 4, y + 4))/(r3*r1 + r2*dampL0(x + 2, y + 2));

    }

}


__global__ void second_section(float* __restrict__ vp_dev, 
                              float* __restrict__ rec_coords_dev, 
                              float* __restrict__ rec_dev,
                              float* __restrict__ v_dev,
                              const long p_rec_stride0,
                              const long  y_stride1, 
                              const long  d_stride0, 
                              const long  x_m, 
                              const long  y_m, 
                              const long  x_M, 
                              const long  y_M, 
                              const float dt, 
                              const float o_x, 
                              const float o_y, 
                              const long  p_rec_m, 
                              const long  p_rec_M,
                              const long  time,
                              const long  t1,
                              const long  x_stride0,
                              const long  y_stride0){ 

          const long  p_rec=blockDim.x*blockIdx.x+threadIdx.x+p_rec_m;

          if(p_rec<p_rec_M){

              long  posx = (long )(floorf(1.0e-1*(-o_x + rec_coordsL0(p_rec, 0))));
              long  posy = (long )(floorf(1.0e-1*(-o_y + rec_coordsL0(p_rec, 1))));
              float px = 1.0e-1F*(-o_x + rec_coordsL0(p_rec, 0)) - floorf(1.0e-1F*(-o_x + rec_coordsL0(p_rec, 0)));
              float py = 1.0e-1F*(-o_y + rec_coordsL0(p_rec, 1)) - floorf(1.0e-1F*(-o_y + rec_coordsL0(p_rec, 1)));

              float tmp=(dt*dt)*(vpL0(posx + 2, posy + 2)*vpL0(posx + 2, posy + 2))*recL0(time, p_rec);

              for (long  rrecx = 0; rrecx <= 1; rrecx += 1){
                  for (long  rrecy = 0; rrecy <= 1; rrecy += 1){
                      if (rrecx + posx >= x_m - 1 && rrecy + posy >= y_m - 1 && rrecx + posx <= x_M + 1 && rrecy + posy <= y_M + 1)
                      {
                          float r0 = tmp*(rrecx*px + (1 - rrecx)*(1 - px))*(rrecy*py + (1 - rrecy)*(1 - py));
                          atomicAdd(&vL0(t1, rrecx + posx + 4, rrecy + posy + 4), r0); 
                      }
                  }
              }

        }
    }

__global__ void third_section(float* __restrict__ grad_dev, 
                              float* __restrict__ v_dev, 
                              float* __restrict__ u_dev,
                              const float r1, 
                              const long  time, 
                              const long  t0, 
                              const long  t1, 
                              const long  t2, 
                              const long  y_stride2, 
                              const long  x_stride0, 
                              const long  y_stride0, 
                              const long  x_m, 
                              const long  x_M, 
                              const long  y_m, 
                              const long  y_M){

    const long  x=blockDim.x*blockIdx.x+threadIdx.x+x_m;
    const long  y=blockDim.y*blockIdx.y+threadIdx.y+y_m;


    if(x<x_M && y<y_M){
        gradL0(x + 1, y + 1) += -(r1*(-2.0F*vL0(t0, x + 4, y + 4)) + r1*vL0(t1, x + 4, y + 4) + r1*vL0(t2, x + 4, y + 4))*uL0(time, x + 4, y + 4);
    }

    
}


extern "C" long  Gradient(struct dataobj *__restrict__ damp_vec, struct dataobj *__restrict__ grad_vec, struct dataobj *__restrict__ rec_vec, struct dataobj *__restrict__ rec_coords_vec, struct dataobj *__restrict__ u_vec, struct dataobj *__restrict__ v_vec, struct dataobj *__restrict__ vp_vec, const long  x_M, const long  x_m, const long  y_M, const long  y_m, const float dt, const float o_x, const float o_y, const long  p_rec_M, const long  p_rec_m, const long  time_M, const long  time_m, const long  deviceid, const long  devicerm, struct profiler * timers);

long  Gradient(struct dataobj *__restrict__ damp_vec, struct dataobj *__restrict__ grad_vec, struct dataobj *__restrict__ rec_vec, struct dataobj *__restrict__ rec_coords_vec, struct dataobj *__restrict__ u_vec, struct dataobj *__restrict__ v_vec, struct dataobj *__restrict__ vp_vec, const long  x_M, const long  x_m, const long  y_M, const long  y_m, const float dt, const float o_x, const float o_y, const long  p_rec_M, const long  p_rec_m, const long  time_M, const long  time_m, const long  deviceid, const long  devicerm, struct profiler * timers)
{

  if (deviceid != -1)
  {
    cudaSetDevice(deviceid);
  }


  float *damp = (float *) damp_vec->data;
  float *grad = (float *) grad_vec->data;
  float *rec = (float *) rec_vec->data;
  float *rec_coords = (float *) rec_coords_vec->data;
  float *u = (float *) u_vec->data;
  float *v = (float *) v_vec->data;
  float *vp = (float *) vp_vec->data;

  float *damp_dev;
  float *grad_dev;
  float *rec_dev;
  float *rec_coords_dev;
  float *u_dev;
  float *v_dev;
  float *vp_dev;

  cudaMalloc((void**)&damp_dev,sizeof(float)*(damp_vec->size[0]*damp_vec->size[1]));
  cudaMalloc((void**)&grad_dev,sizeof(float)*(grad_vec->size[0]*grad_vec->size[1]));
  cudaMalloc((void**)&rec_dev,sizeof(float)*(rec_vec->size[0]*rec_vec->size[1]));
  cudaMalloc((void**)&rec_coords_dev,sizeof(float)*(rec_coords_vec->size[0]*rec_coords_vec->size[1]));
  cudaMalloc((void**)&u_dev,sizeof(float)*(u_vec->size[0]*u_vec->size[1]*u_vec->size[2]));
  cudaMalloc((void**)&v_dev,sizeof(float)*(v_vec->size[0]*v_vec->size[1]*v_vec->size[2]));
  cudaMalloc((void**)&vp_dev,sizeof(float)*(vp_vec->size[0]*vp_vec->size[1]));

  cudaMemcpy(damp_dev,damp,sizeof(float)*(damp_vec->size[0]*damp_vec->size[1]),cudaMemcpyHostToDevice); 
  cudaMemcpy(grad_dev,grad,sizeof(float)*(grad_vec->size[0]*grad_vec->size[1]),cudaMemcpyHostToDevice); 
  cudaMemcpy(rec_dev,rec,sizeof(float)*(rec_vec->size[0]*rec_vec->size[1]),cudaMemcpyHostToDevice); 
  cudaMemcpy(rec_coords_dev,rec_coords,sizeof(float)*(rec_coords_vec->size[0]*rec_coords_vec->size[1]),cudaMemcpyHostToDevice); 
  cudaMemcpy(u_dev,u,sizeof(float)*(u_vec->size[0]*u_vec->size[1]*u_vec->size[2]),cudaMemcpyHostToDevice); 
  cudaMemcpy(v_dev,v,sizeof(float)*(v_vec->size[0]*v_vec->size[1]*v_vec->size[2]),cudaMemcpyHostToDevice); 
  cudaMemcpy(vp_dev,vp,sizeof(float)*(vp_vec->size[0]*vp_vec->size[1]),cudaMemcpyHostToDevice); 


  const long  x_fsz0 = v_vec->size[1];
  const long  y_fsz0 = v_vec->size[2];
  const long  y_fsz1 = vp_vec->size[1];
  const long  y_fsz2 = grad_vec->size[1];
  const long  p_rec_fsz0 = rec_vec->size[1];
  const long  d_fsz0 = rec_coords_vec->size[1];

  const long  x_stride0 = x_fsz0*y_fsz0;
  const long  y_stride0 = y_fsz0;
  const long  y_stride1 = y_fsz1;
  const long  y_stride2 = y_fsz2;
  const long  p_rec_stride0 = p_rec_fsz0;
  const long  d_stride0 = d_fsz0;

  float r1 = 1.0F/(dt*dt);
  float r2 = 1.0F/dt;


  dim3 block_x_y(NTHX,NTHY);  // 16x16 threads per block
  dim3 grid_x_y((x_M - x_m + block_x_y.x) / block_x_y.x, (y_M - y_m + block_x_y.y) / block_x_y.y);


  dim3 p_rec_block(NTH);
  dim3 p_rec_grid((p_rec_M-p_rec_m+NTH)/NTH);


  for (long  time = time_M, t0 = (time)%(3), t1 = (time + 2)%(3), t2 = (time + 1)%(3); time >= time_m; time -= 1, t0 = (time)%(3), t1 = (time + 2)%(3), t2 = (time + 1)%(3))
  {
    START(section0)

      first_section<<<grid_x_y,block_x_y>>>(vp_dev,v_dev,damp_dev,r2,r1,x_m,x_M,y_m,y_M,x_stride0,y_stride0,y_stride1,t0,t1,t2);
      cudaDeviceSynchronize();

    STOP(section0,timers)


    START(section1)

      
      if (rec_vec->size[0]*rec_vec->size[1] > 0 && p_rec_M - p_rec_m + 1 > 0)
      {
        second_section<<<p_rec_grid,p_rec_block>>>(vp_dev,rec_coords_dev,rec_dev,v_dev,p_rec_stride0,y_stride1,d_stride0,x_m,y_m,x_M,y_M,dt,o_x,o_y,p_rec_m,p_rec_M,time,t1,x_stride0,y_stride0);
        cudaDeviceSynchronize();
      }

    STOP(section1,timers)

    START(section2)

      third_section<<<grid_x_y,block_x_y>>>(grad_dev,v_dev,u_dev,r1,time,t0,t1,t2,y_stride2,x_stride0,y_stride0,x_m,x_M,y_m,y_M);
      cudaDeviceSynchronize();

    STOP(section2,timers)


  }

  printf("Timers sec1 %10.6f sec2 %10.6f sec3 %10.6f \n",timers->section0, timers->section1, timers-> section2);

  cudaMemcpy(grad,grad_dev,sizeof(float)*(grad_vec->size[0]*grad_vec->size[1]),cudaMemcpyDeviceToHost); 
  cudaMemcpy(v,v_dev,sizeof(float)*(v_vec->size[0]*v_vec->size[1]*v_vec->size[2]),cudaMemcpyDeviceToHost); 

  cudaFree(grad_dev);
  cudaFree(v_dev);

  cudaFree(damp_dev);
  cudaFree(rec_dev);
  cudaFree(rec_coords_dev);
  cudaFree(u_dev);
  cudaFree(vp_dev);

  cudaDeviceSynchronize();


  return 0;
}
