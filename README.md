# Validating Queries in Attribute Extraction from Japanese Wikipedia
 
This repository is an implementation used in "Validating Queries in Attribute Extraction from Japanese Wikipedia."

## Operating Environment
You can use Dockerfile to construct the operating environment.

```bash
cd docker
docker build -t [image_name] .
```
### Requirement
* python 3.7.9 
* sklearn 0.23.2
* transformer 4.0.0
* pytorch 1.6.0

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

 