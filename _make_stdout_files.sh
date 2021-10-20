output_dir=$1

## ディレクトリがなければ作成
if [ -d ./${output_dir} ] ;then
echo 'There is a ${output_dir} directory.'
else
mkdir ${output_dir}
fi

## ファイルがなければ作成
if [ -f ./${output_dir}/stdout_train.txt ] ;then
echo 'There is a stdout_train file.'
else
touch ./${output_dir}/stdout_train.txt
fi

if [ -f ./${output_dir}/stdout_pred.txt ] ;then
echo 'There is a stdout_pred file.'
else
touch ./${output_dir}/stdout_pred.txt
fi

if [ -f ./${output_dir}/stdout_score.txt ] ;then
echo 'There is a stdout_score file.'
else
touch ./${output_dir}/stdout_score.txt
fi