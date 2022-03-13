group=JP-5
data_dir=../data
output_dir=${data_dir}/Examples
datasets_dir=${data_dir}/${group}/annotation
WikiID_dir=${data_dir}/WikipediaID

example_num=1
seed=41
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=42
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=43
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=44
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=45
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}


example_num=5
seed=41
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=42
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=43
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=44
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=45
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}


example_num=10
seed=41
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=42
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=43
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=44
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}
seed=45
echo ${seed}
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir} --seed ${seed}