# Validating Queries in Attribute Extraction from Japanese Wikipedia
 
This repository is an implementation used in "Validating Queries in Attribute Extraction from Japanese Wikipedia."

## Operating Environment
You can use Dockerfile to construct the operating environment.

```bash
cd docker
docker build -t [image_name] .
docker run -it -v /home:/home --name [containe_name] [image_name] /bin/bash
```

### Requirement
* python 3.8.10
* transformer 2.11.0
* pytorch : 1.9.1+cu111

## Dataset
使用するデータセットについて

 
## Query Generation
 
```bash
./convert_shinra_to_squad.sh JP-5/ output_dir_name/
```
 
## Train
```bash
./bert_squad.sh 
```

 