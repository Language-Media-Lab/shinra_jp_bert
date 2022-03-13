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

## query1
work_dir=${data_dir}/2019JP_attr/${mode}-${label}
output_dir=query1_2019JP_attr
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    # 分散学習を行う場合
    #python3 -m torch.distributed.launch  --nproc_per_node=4 --nnodes=1 --node_rank 0  bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    BEST_EPOCH=${?}
    # ターゲットタスクの予測
    python3 bert_squad.py --do_predict --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir} --output ${output_dir} >> ${output_dir}/stdout_pred.txt
    # スコアリング
    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${test_batch_size} ${group_dir} ${prefix} ${test_case_str} ${output_dir} >> ${output_dir}/stdout_score.txt ${work_dir}
done

## query2
work_dir=${data_dir}/2019JP_attr_q/${mode}-${label}
output_dir=query2_2019JP_attr_q
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    # 分散学習を行う場合
    #python3 -m torch.distributed.launch  --nproc_per_node=4 --nnodes=1 --node_rank 0  bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    BEST_EPOCH=${?}
    # ターゲットタスクの予測
    python3 bert_squad.py --do_predict --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir} --output ${output_dir} >> ${output_dir}/stdout_pred.txt
    # スコアリング
    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${test_batch_size} ${group_dir} ${prefix} ${test_case_str} ${output_dir} >> ${output_dir}/stdout_score.txt ${work_dir}
done

## query3
work_dir=${data_dir}/2019JP_attr_5W1H_q/${mode}-${label}
output_dir=query3_2019JP_attr_5W1H_q
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    # 分散学習を行う場合
    #python3 -m torch.distributed.launch  --nproc_per_node=4 --nnodes=1 --node_rank 0  bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    BEST_EPOCH=${?}
    # ターゲットタスクの予測
    python3 bert_squad.py --do_predict --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir} --output ${output_dir} >> ${output_dir}/stdout_pred.txt
    # スコアリング
    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${test_batch_size} ${group_dir} ${prefix} ${test_case_str} ${output_dir} >> ${output_dir}/stdout_score.txt ${work_dir}
done

## query4
work_dir=${data_dir}/2019JP_title_attr/${mode}-${label}
output_dir=query4_2019JP_title_attr
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    # 分散学習を行う場合
    #python3 -m torch.distributed.launch  --nproc_per_node=4 --nnodes=1 --node_rank 0  bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    BEST_EPOCH=${?}
    # ターゲットタスクの予測
    python3 bert_squad.py --do_predict --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir} --output ${output_dir} >> ${output_dir}/stdout_pred.txt
    # スコアリング
    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${test_batch_size} ${group_dir} ${prefix} ${test_case_str} ${output_dir} >> ${output_dir}/stdout_score.txt ${work_dir}
done

## query5
work_dir=${data_dir}/2019JP_title_attr_q/${mode}-${label}
output_dir=query5_2019JP_title_attr_q
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    # 分散学習を行う場合
    #python3 -m torch.distributed.launch  --nproc_per_node=4 --nnodes=1 --node_rank 0  bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    BEST_EPOCH=${?}
    # ターゲットタスクの予測
    python3 bert_squad.py --do_predict --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir} --output ${output_dir} >> ${output_dir}/stdout_pred.txt
    # スコアリング
    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${test_batch_size} ${group_dir} ${prefix} ${test_case_str} ${output_dir} >> ${output_dir}/stdout_score.txt ${work_dir}
done

## query6
work_dir=${data_dir}/2019JP_title_attr_5W1H_q/${mode}-${label}
output_dir=query6_2019JP_title_attr_5W1H_q
categories="Person Company City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    # 分散学習を行う場合
    #python3 -m torch.distributed.launch  --nproc_per_node=4 --nnodes=1 --node_rank 0  bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training --fp16
    BEST_EPOCH=${?}
    # ターゲットタスクの予測
    python3 bert_squad.py --do_predict --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir} --output ${output_dir} >> ${output_dir}/stdout_pred.txt
    # スコアリング
    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${test_batch_size} ${group_dir} ${prefix} ${test_case_str} ${output_dir} >> ${output_dir}/stdout_score.txt ${work_dir}
done