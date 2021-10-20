#!/bin/bash
cat <<__EOT__
TARGET=$1
LR=$2
EPOCH=$3
data_dir=$4
prefix=$5
test_case_str=$6
output_dir=$7
aug_prefix=$8
# sample_size=$6
__EOT__

TARGET=$1
LR=$2
EPOCH=$3
data_dir=$4
prefix=$5
test_case_str=$6
output_dir=$7
aug_prefix=$8


batch_size=32
eval_batch_size=32
max_seq_length=384
doc_stride=128

model_dir=./${output_dir}/${TARGET}_${test_case_str}_train_batch${batch_size}_epoch10_lr${LR}_seq${max_seq_length}${aug_prefix}

scorer_dir=./shinra_jp_scorer
target_dir=./data/2019JP/train-shinra_jp_bert_html

echo "EPOCH="${EPOCH}

python3 regulation_bio.py --predicate_json ${model_dir}/epoch-${EPOCH}/shinra_${TARGET}_test_results.json --category ${TARGET} --html_dir ${data_dir}/html/${TARGET} --prefix ${prefix}  --dist_file ${data_dir}/annotation/${TARGET}_dist.json
## --targetがあってもなくても変わらない？？
python3 ${scorer_dir} --target ${target_dir}/${TARGET}-test-id.txt --html ${data_dir}/html/${TARGET} --score ${model_dir}/epoch-${EPOCH}/scorer_score_${TARGET}${prefix} ${data_dir}/annotation/${TARGET}_dist.json  ${model_dir}/epoch-${EPOCH}/shinra_${TARGET}_test_results.reg${prefix}.json
#python3 ${scorer_dir} --html ${data_dir}/html/${TARGET} --score ${model_dir}/epoch-${EPOCH}/scorer_score_${TARGET}${prefix} ${data_dir}/annotation/${TARGET}_dist.json  ${model_dir}/epoch-${EPOCH}/shinra_${TARGET}_test_results.reg${prefix}.json