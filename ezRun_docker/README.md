# Working with this `Docker` contaier

## Building the image locally
1.  Clone the repo locally
```
git clone https://github.com/dktanwar/urpp_docker.git
```

2. Enter into directory
```
cd urpp_docker
```

3. Build image locally and call it as bsseq
```
docker build . -t bsseq
```

## Entering into container and running analysis

1. Enter into container while mounting directory
```
docker run --rm -it --entrypoint /bin/bash -v /mnt/:/home/rstudio bsseq 
```
_You are mounting `/mnt/` of your computer to `/home/rstudio` of container_

2. Go to the mounted place
```
cd /home/rstudio
```
_Here, you would see the content of `/mnt/` of your computer_

3. Make a project directory somewhere on `/home/rstudio/where/you/want`
```
cd /home/rstudio/where/you/want
create_project myProject
cd myProject
```

4. Run your analysis
Here, you would see the structure from [dktanwar/project_structure](https://github.com/dktanwar/project_structure)


## Running Rstudio server
```
docker run --rm -p 8780:8787 -e PASSWORD=pass bsseq
```

## Also, mouning a directory
```
docker run --rm -p 8780:8787 -e PASSWORD=pass -v /mnt/:/home/rstudio bsseq
```
## Running shiny server
```
docker run -p 3838:3838 --rm bsseq /usr/bin/shiny-server
```
