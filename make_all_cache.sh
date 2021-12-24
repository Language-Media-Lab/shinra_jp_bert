#!/bin/bash
export LANG=ja_JP.UTF-8

batch_size=32
eval_batch_size=32
test_batch_size=32
max_seq_length=384
doc_stride=128
mode=train
label=shinra_jp_bert_html
data_dir=../data
html_data_dir=../data
LR=2e-05
prefix=simple
GROUP=JP5
test_case_str=shinra_jp_bert_html_${GROUP}
group_dir=${html_data_dir}/JP-5


# 1.属性値
work_dir=${data_dir}/2019JP_attr/${mode}-${label}
output_dir=output_2019JP_attr
## 標準出力を保存するファイルを生成
bash _make_stdout_files.sh ${output_dir}
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    ## STILTs無しの場合は以下のコード（--model_name_or_pathが無い）
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training >> ${output_dir}/stdout_train.txt --make_cache --no_cuda
done

# 2.属性値+？
work_dir=${data_dir}/2019JP_attr_q/${mode}-${label}
output_dir=output_2019JP_attr_q
## 標準出力を保存するファイルを生成
bash _make_stdout_files.sh ${output_dir}
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    ## STILTs無しの場合は以下のコード（--model_name_or_pathが無い）
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training >> ${output_dir}/stdout_train.txt --make_cache --no_cuda
done

# 3.属性値+5W1H+？
work_dir=${data_dir}/2019JP_attr_5W1H_q/${mode}-${label}
output_dir=output_2019JP_attr_5W1H_q
## 標準出力を保存するファイルを生成
bash _make_stdout_files.sh ${output_dir}
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    ## STILTs無しの場合は以下のコード（--model_name_or_pathが無い）
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training >> ${output_dir}/stdout_train.txt --make_cache --no_cuda
done



######以下title含む


# 4.title+属性値
work_dir=${data_dir}/2019JP_title_attr/${mode}-${label}
output_dir=output_2019JP_title_attr
## 標準出力を保存するファイルを生成
bash _make_stdout_files.sh ${output_dir}
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    ## STILTs無しの場合は以下のコード（--model_name_or_pathが無い）
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training >> ${output_dir}/stdout_train.txt --make_cache --no_cuda
done

# 5.title+属性値+？
work_dir=${data_dir}/2019JP_title_attr_q/${mode}-${label}
output_dir=output_2019JP_title_attr_q
## 標準出力を保存するファイルを生成
bash _make_stdout_files.sh ${output_dir}
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    ## STILTs無しの場合は以下のコード（--model_name_or_pathが無い）
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training >> ${output_dir}/stdout_train.txt --make_cache --no_cuda
done

# 6.title+属性値+5W1H+？
work_dir=${data_dir}/2019JP_title_attr_5W1H_q/${mode}-${label}
output_dir=output_2019JP_title_attr_5W1H_q
## 標準出力を保存するファイルを生成
bash _make_stdout_files.sh ${output_dir}
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    ## STILTs無しの場合は以下のコード（--model_name_or_pathが無い）
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training >> ${output_dir}/stdout_train.txt --make_cache --no_cuda
done


