#!/bin/bash
export LANG=ja_JP.UTF-8

batch_size=32
eval_batch_size=32
max_seq_length=384
doc_stride=128
mode=train
label=shinra_jp_bert_html
test_case_str=shinra_jp_bert_html
data_dir=./data

work_dir=${data_dir}/2019JP_fixerror/${mode}-${label}
output_dir=output_2019JP_ishii_baseline_City_fixerror

html_data_dir=./data
LR=2e-05
prefix=simple

GROUP=JP5

test_case_str=${test_case_str}_${GROUP}
group_dir=${html_data_dir}/JP-5

## 標準出力を保存するファイルを生成
bash _make_stdout_files.sh ${output_dir}

#categories_comma="Compound,Person,Company,City,Airport"
# カテゴリ横断の学習
#python3 bert_squad.py --do_train --group ${GROUP} --categories ${categories_comma} --not_with_negative --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training
# カテゴリ横断のbest model
#best_model_path=./output_question/${GROUP}_${test_case_str}_train_batch${batch_size}_epoch10_lr${LR}_seq${max_seq_length}/epoch-9

# カテゴリ横断しない場合
best_model_path=./models/NICT_BERT-base_JapaneseWikipedia_32K_BPE

#categories="Person Company City Airport Compound"
#categories="Person Company City"
categories="City"
for target in ${categories[@]}; do
    echo $target
    # ターゲットカテゴリの学習
    ## STILTs有りの場合は以下のコード（--model_name_or_pathがある）
    #python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --model_name_or_path ${best_model_path} --output ${output_dir} --evaluate_during_training
    ## STILTs無しの場合は以下のコード（--model_name_or_pathが無い）
    BEST_EPOCH=$(python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir} --output ${output_dir} --evaluate_during_training >> ${output_dir}/stdout_train.txt)
    #BEST_EPOCH=9
    # ターゲットタスクの予測
    python3 bert_squad.py --do_predict --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir} --output ${output_dir} >> ${output_dir}/stdout_pred.txt
    # スコアリング
    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${group_dir} ${prefix} ${test_case_str} ${output_dir} >> ${output_dir}/stdout_score.txt
done

##GROUP=Organization
##test_case_str=${test_case_str}_${GROUP}
##group_dir=${html_data_dir}/${GROUP}
##categories=(Organization_Other)
##best_epochs=(7)
##i=0
##for target in ${categories[@]}; do
##    echo ${target} ${best_epochs[i]}
##    target=${categories[i]}
##    BEST_EPOCH=${best_epochs[i]}
##    python3 bert_squad.py --category ${target} --do_predict --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir}
##    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${group_dir} ${prefix} ${test_case_str}
##    let i++
##done
##
##GROUP=Location
##test_case_str=${test_case_str}_${GROUP}
##group_dir=${html_data_dir}/${GROUP}
##categories="Location_Other GPE_Other Province Country Continental_Region Domestic_Region Geological_Region_Other Spa Mountain Island River Lake Sea Bay"
##categories_comma="Location_Other,GPE_Other,Province,Country,Continental_Region,Domestic_Region,Geological_Region_Other,Spa,Mountain,Island,River,Lake,Sea,Bay"

# python3 bert_squad.py --group ${GROUP} --categories ${categories_comma} --not_with_negative --do_train --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${work_dir}
# exit 0

##best_model_path=../transformers/output/shinra_${GROUP}_${test_case_str}_train_batch${batch_size}_epoch10.0_lr${LR}_seq${max_seq_length}/epoch-7
##
##categories=(GPE_Other Country Continental_Region Domestic_Region Geological_Region_Other Spa Mountain Island River Lake Sea)
##best_epochs=(5 8 8 3 0 3 6 1 3 8 3)
##i=0
##for target in ${categories[@]}; do
##    echo ${target} ${best_epochs[i]}
##    target=${categories[i]}
##    BEST_EPOCH=${best_epochs[i]}
##    python3 bert_squad.py --category ${target} --do_predict --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --best_model_dir /epoch-${BEST_EPOCH} --data_dir ${work_dir}
##    bash _bert_squad_scorer.sh ${target} ${LR} ${BEST_EPOCH} ${group_dir} ${prefix} ${test_case_str}
##    let i++
##done
##
##GROUP=Event
##augmentation=
##best_model_path=./transformers/output/shinra_${GROUP}_${test_case_str}_${GROUP}_train_batch${batch_size}_epoch10.0_lr${LR}_seq${max_seq_length}/epoch-9
##test_case_str=${test_case_str}_${GROUP}
##group_dir=${html_data_dir}/${GROUP}
##categories="Competition Conference Earthquake Election Event_Other Exhibition Flood_Damage Incident_Other Occasion_Other Religious_Festival Traffic_Accident War"
##categories_comma="Competition,Conference,Earthquake,Election,Event_Other,Exhibition,Flood_Damage,Incident_Other,Occasion_Other,Religious_Festival,Traffic_Accident,War"
##python3 bert_squad.py --group ${GROUP} --categories ${categories_comma} --not_with_negative --do_train --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${data_dir} --make_cache --overwrite_cache --train_all_data
##test_case_str=${test_case_str}_${GROUP}
##for target in ${categories[@]}; do
##    echo $target
##    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${data_dir} --model_name_or_path ${best_model_path} --make_cache  --overwrite_cache --train_all_data
##done
##
##GROUP=Facility
##best_model_path=./transformers/output/shinra_${GROUP}_${test_case_str}_${GROUP}_train_batch${batch_size}_epoch10.0_lr${LR}_seq${max_seq_length}/epoch-9
##test_case_str=${test_case_str}_${GROUP}
##group_dir=${html_data_dir}/${GROUP}
##categories="Facility_Other Dam Archaeological_Place_Other Cemetery FOE_Other Military_Base Castle Palace Public_Institution Accommodation Medical_Institution School Research_Institute Power_Plant Park Shopping_Complex Sports_Facility Museum Zoo Amusement_Park Theater Worship_Place Car_Stop Station Port Road_Facility Railway_Facility Line_Other Railroad Road Canal Tunnel Bridge"
##categories_comma="Facility_Other,Dam,Archaeological_Place_Other,Cemetery,FOE_Other,Military_Base,Castle,Palace,Public_Institution,Accommodation,Medical_Institution,School,Research_Institute,Power_Plant,Park,Shopping_Complex,Sports_Facility,Museum,Zoo,Amusement_Park,Theater,Worship_Place,Car_Stop,Station,Port,Road_Facility,Railway_Facility,Line_Other,Railroad,Road,Canal,Tunnel,Bridge"
##python3 bert_squad.py --group ${GROUP} --categories ${categories_comma} --not_with_negative --do_train --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${data_dir} --make_cache --overwrite_cache --train_all_data
##test_case_str=${test_case_str}_${GROUP}
##for target in ${categories[@]}; do
##    echo $target
##    python3 bert_squad.py --do_train --category ${target} --per_gpu_train_batch_size ${batch_size} --per_gpu_eval_batch_size ${eval_batch_size} --learning_rate ${LR} --max_seq_length ${max_seq_length} --doc_stride ${doc_stride} --test_case_str ${test_case_str} --data_dir ${data_dir} --model_name_or_path ${best_model_path} --make_cache  --overwrite_cache --train_all_data
##done
##