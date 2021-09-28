# Emerald docked

A docker solution to ease Gem5 Emerald setup. 

These instructions will help you set everything needed for this image:

- Docker
- Nvidia Container runtime
- x11docker

Once you have all that you are set.

I presume you are using an Ubuntu or Debian system, you might have to look elsewhere if you are using another distribution. And if you are using Windows... Well, bless you.

## Setting up the image

Other than having docker installed, you will need to set up the *Nvidia Container runtime* and *x11docker*.

### Nvidia Container runtime

To install the *Nvidia Container runtime* we do:

```
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list |\
    sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
sudo apt-get install nvidia-container-runtime
```

We have to restart Docker:

```
sudo systemctl stop docker
sudo systemctl start docker
```

You can check if it worked by:

```
docker run --gpus all nvidia/cuda:10.2-cudnn7-devel nvidia-smi
```

### X11docker

You'll need to do:

```
sudo apt-get -y install xpra xserver-xephyr xinit xauth xclip x11-xserver-utils x11-utils
curl -fsSL https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker | sudo bash -s -- --update
```

## Using the image

I recommend building the image as such:

```
docker build -t $(basename $PWD) .
```

But you are free to name it however you want.

You need to give access to the Xserver in your machine with:

```
xhost local:root
```
 
And start it with:

```
docker run --rm -it --net=host -e DISPLAY=$DISPLAY emerald-docked
```