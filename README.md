# Validating Queries in Attribute Extraction from Japanese Wikipedia
 
This repository is an implementation used in "Validating Queries in Attribute Extraction from Japanese Wikipedia."

## Operating Environment
You can use Dockerfile to construct the operating environment.

```bash
cd docker
docker build -t [image_name] .
docker run -it -v /home:/home --name [containe_name] [image_name] /bin/bash
```

## Data & models
You need to download the [pre-trained BERT model (NICT BERT 日本語PretrainedモデルBPE あり)](https://alaginrc.nict.go.jp/nict-bert/NICT_BERT-base_JapaneseWikipedia_32K_BPE.zip) and the [preprocessed dataset (Shinra2019-JP)](http://shinra-project.info/download/?tax%5Bwpdmcategory%5D=2019jp#) and the [MeCab-Juman Dictionary](https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7X2pESGlLREpxdXM), and unzip these zip files.
 
[MeCab-Juman Dictionary](https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7X2pESGlLREpxdXM) 

## Query Generation

```bash
code/make_example.sh
code/convert_shinra_to_squad.sh JP-5/ output_dir_name/
code/make_all_baseline_query.sh
code/make_all_example_query.sh
```
 
## Train 
```bash
code/bert_squad.sh 
```

 