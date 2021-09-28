FROM ubuntu:18.04

# Ask docker to use bash
SHELL ["/bin/bash", "-c"]

# Set GPU availability
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

# Ubuntu needs this
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Madrid
RUN apt-get update -y && apt-get install -y tzdata

# Packages needed
RUN apt-get install -y --no-install-recommends git 
RUN apt-get install -y --no-install-recommends g++ 
RUN apt-get install -y --no-install-recommends g++-5 
RUN apt-get install -y --no-install-recommends gcc-5 
RUN apt-get install -y --no-install-recommends python 
RUN apt-get install -y --no-install-recommends python-pip 
RUN apt-get install -y --no-install-recommends build-essential 
RUN apt-get install -y --no-install-recommends checkinstall 
RUN apt-get install -y --no-install-recommends libreadline-gplv2-dev 
RUN apt-get install -y --no-install-recommends libncursesw5-dev 
RUN apt-get install -y --no-install-recommends libssl-dev 
RUN apt-get install -y --no-install-recommends libsqlite3-dev 
RUN apt-get install -y --no-install-recommends tk-dev 
RUN apt-get install -y --no-install-recommends libgdbm-dev 
RUN apt-get install -y --no-install-recommends libc6-dev 
RUN apt-get install -y --no-install-recommends libbz2-dev 
RUN apt-get install -y --no-install-recommends scons 
RUN apt-get install -y --no-install-recommends swig 
RUN apt-get install -y --no-install-recommends m4 
RUN apt-get install -y --no-install-recommends autoconf 
RUN apt-get install -y --no-install-recommends automake 
RUN apt-get install -y --no-install-recommends libtool 
RUN apt-get install -y --no-install-recommends curl 
RUN apt-get install -y --no-install-recommends make 
RUN apt-get install -y --no-install-recommends cmake 
RUN apt-get install -y --no-install-recommends unzip 
RUN apt-get install -y --no-install-recommends python-pydot 
RUN apt-get install -y --no-install-recommends flex 
RUN apt-get install -y --no-install-recommends bison 
RUN apt-get install -y --no-install-recommends xutils 
RUN apt-get install -y --no-install-recommends libx11-dev 
RUN apt-get install -y --no-install-recommends libxt-dev 
RUN apt-get install -y --no-install-recommends libxmu-dev 
RUN apt-get install -y --no-install-recommends libxi-dev 
RUN apt-get install -y --no-install-recommends libgl1-mesa-dev 
RUN apt-get install -y --no-install-recommends python-dev 
RUN apt-get install -y --no-install-recommends imagemagick 
RUN apt-get install -y --no-install-recommends libpng-dev 
RUN apt-get install -y --no-install-recommends gettext

# Needed for git cloning
RUN apt-get install -y \
        ca-certificates \
        && update-ca-certificates

# We will need cuda
RUN apt-get install -y nvidia-cuda-toolkit

# We need mako for mesa compiling
RUN pip install mako

#Clone and build ApiTrace
RUN mkdir emerald 
WORKDIR /emerald
RUN git clone https://github.com/gem5-graphics/apitrace
WORKDIR /emerald/apitrace
RUN mkdir build 
WORKDIR /emerald/apitrace/build
RUN cmake .. 
RUN make 
WORKDIR /emerald
RUN git clone --recursive https://github.com/gem5-graphics/gem5-graphics.git 

# Set environment variables
ENV CUDAHOME=/usr/lib/cuda/ 
ENV NVIDIA_CUDA_SDK_LOCATION=/usr/lib/cuda
ENV APITRACE_LIB_PATH=/emerald/apitrace/build/retrace/libglretrace.so
ENV LD_LIBRARY_PATH=/emerald/gem5-graphics/mesa/lib
ENV LD_LIBRARY_PATH=/emerald/gem5-graphics/mesa/lib/gallium
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/emerald/gem5-graphics/android_libs
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDAHOME/lib
ENV GPGPUSIM_MESA_ROOT=/emerald/gem5-graphics
ENV PATH=$PATH:$CUDAHOME/bin
ENV PATH=$PATH:/emerald/gem5-graphics/gem5/util/term
ENV CUDA_INSTALL_PATH=$CUDAHOME
ENV ANDROID_GL_SOFTWARE_RENDERER=1
ENV LIBGL_DRIVERS_PATH=/emerald/gem5-graphics/mesa/lib/gallium
ENV ANDROID_EGL_LIB=/emerald/gem5-graphics/mesa/lib/libEGL.so
ENV ANDROID_GLESv2_LIB=/emerald/gem5-graphics/mesa/lib/libGLESv2.so


WORKDIR /emerald/gem5-graphics/mesa
RUN ./autogen.sh --enable-gallium-swrast --with-gallium-drivers=swrast --disable-gallium--llvm --disable-dri --disable-gbm --disable-egl 
RUN make 
RUN cp lib/gallium/libGL.so lib/gallium/libswrast_dri.so 

RUN \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 10 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 10

WORKDIR /emerald/gem5-graphics/gem5
RUN scons build/ARM/gem5.debug EXTRAS=../gem5-gpu/src:../gpgpu-sim -j4

    

WORKDIR /emerald/gem5-graphics/gem5