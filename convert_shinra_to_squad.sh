#!/bin/bash
cat <<__EOT__
group=$1
__EOT__
group=$1

mode=train
label=shinra_jp_bert_html

data_dir=../..
work_dir=${data_dir}/shinra_to_squad_knowledge/${mode}-${label}
mkdir -p ${work_dir}

# unzip ${data_dir}/${group}.zip -d ${data_dir}
html_dir=${data_dir}/${group}/html
datasets_dir=${data_dir}/${group}/annotation
array=($(find ${html_dir} -maxdepth 1 -type d))
for obj in "${array[@]}"; do
  if [ $obj = ${html_dir} ]; then
    continue
  fi
  target=($(basename $obj))
  echo $target
  python shinra_to_squad.py --input ${datasets_dir}/${target}_dist.json --output ${work_dir}/squad_${target}.json --attribute_to_qa ${datasets_dir}/attribute_to_qa.json --html_dir ${html_dir}/${target} --html_tag

done
