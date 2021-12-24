#!/bin/bash
cat <<__EOT__
group=$1
__EOT__
group=$1
dir_name=$2
#question_type=$3

mode=train
label=shinra_jp_bert_html
question_type="attribute,question,example"
#question_type="attribute,title,question,5W1H,example"
example_num=5

data_dir=../data
work_dir=${data_dir}/${dir_name}/${mode}-${label}
mkdir -p ${work_dir}/WikipediaID

# unzip ${data_dir}/${group}.zip -d ${data_dir}
html_dir=${data_dir}/${group}/html
datasets_dir=${data_dir}/${group}/annotation
example_file_path=${data_dir}/Examples/examples_query_seed42_num${example_num}.json

array=($(find ${html_dir} -maxdepth 1 -type d))
for obj in "${array[@]}"; do
  if [ $obj = ${html_dir} ]; then
    continue
  fi
  target=($(basename $obj))
  echo $target
  python3 shinra_to_squad.py  --category ${target}  --question_type ${question_type} --input ${datasets_dir}/${target}_dist.json --output ${work_dir}/squad_${target}.json --attribute_to_qa ${data_dir}/attribute_to_qa.json --html_dir ${html_dir}/${target} --html_tag --example_file_path ${example_file_path} 
  ## train=85件, dev=5件, test=10件 をサンプリングする場合【デバック用】 
  #python3 shinra_to_squad.py  --train_num 85 --dev_num 5 --test_num 10 --category ${target}  --question_type ${question_type} --input ${datasets_dir}/${target}_dist.json --output ${work_dir}/squad_${target}.json --attribute_to_qa ${data_dir}/attribute_to_qa.json --html_dir ${html_dir}/${target} --html_tag
done
