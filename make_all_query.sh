#question_type="attribute,title,question,5W1H,example"

group=JP-5

question_type=attribute
dir_name=2019JP_attr
bash convert_shinra_to_squad.sh ${group} ${dir_name} ${question_type}

question_type=attribute,question
dir_name=2019JP_attr_q
bash convert_shinra_to_squad.sh ${group} ${dir_name} ${question_type}

question_type=attribute,question,5W1H
dir_name=2019JP_attr_5W1H_q
bash convert_shinra_to_squad.sh ${group} ${dir_name} ${question_type}


question_type=attribute,title
dir_name=2019JP_title_attr
bash convert_shinra_to_squad.sh ${group} ${dir_name} ${question_type}

question_type=attribute,question,title
dir_name=2019JP_title_attr_q
bash convert_shinra_to_squad.sh ${group} ${dir_name} ${question_type}

question_type=attribute,question,5W1H,title
dir_name=2019JP_title_attr_5W1H_q
bash convert_shinra_to_squad.sh ${group} ${dir_name} ${question_type}