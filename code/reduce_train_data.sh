target_dir=$1
data_size=$2
data_dir=../data
new_dir=${data_dir}/reduced${data_size}_${target_dir}

cp -rf ${data_dir}/${target_dir}/train-shinra_jp_bert_html/  ${new_dir}

work_dir=${new_dir}/train-shinra_jp_bert_html
WikiID_dir=${work_dir}/WikipediaID

echo data_size ${data_size}

categories="Person Company City Airport Compound"
for target in ${categories[@]}; do
    echo $target
    python3 reduce_train_data.py  --category ${target} --work_dir ${work_dir} --data_size ${data_size} --wikiID_dir ${WikiID_dir}
done
