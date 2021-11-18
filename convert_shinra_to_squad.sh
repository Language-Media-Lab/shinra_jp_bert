#!/bin/bash
cat <<__EOT__
group=$1
__EOT__
group=$1
dir_name=$2

mode=train
label=shinra_jp_bert_html
#question_type="attribute,title,question,5W1H,example"
question_type="attribute"

data_dir=../data
work_dir=${data_dir}/${dir_name}/${mode}-${label}
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
  #python3 shinra_to_squad.py  --train_num 100 --dev_num 50 --test_num 50 --category ${target}  --question_type ${question_type} --input ${datasets_dir}/${target}_dist.json --output ${work_dir}/squad_${target}.json --attribute_to_qa ${data_dir}/attribute_to_qa.json --html_dir ${html_dir}/${target} --html_tag
  python3 shinra_to_squad.py  --category ${target}  --question_type ${question_type} --input ${datasets_dir}/${target}_dist.json --output ${work_dir}/squad_${target}.json --attribute_to_qa ${data_dir}/attribute_to_qa.json --html_dir ${html_dir}/${target} --html_tag
done
