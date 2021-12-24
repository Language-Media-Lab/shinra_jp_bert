group=JP-5
data_dir=../data
output_dir=${data_dir}/Examples
datasets_dir=${data_dir}/${group}/annotation
example_num=10
WikiID_dir=${data_dir}/WikipediaID
python3 make_example.py  --input ${datasets_dir} --output_dir ${output_dir} --example_num ${example_num} --wikiID_dir ${WikiID_dir}
