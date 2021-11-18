#!/usr/bin/env python3
# Copyright 2021, Nihon Unisys, Ltd.
#
# This source code is licensed under the BSD license.

import argparse
import json
from pathlib import Path
import html_util
import os, os.path
# sys.path.append('../shinra_jp_scorer')
from shinra_jp_scorer.scoring import liner2dict, get_annotation, get_ene

import random

import io,sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

FLAG_ATTRS = ['総称']

#5W1Hと質問文の対応
attribute_to_qa_LIST = {
    "who":"誰", 
    "what":"なん", 
    "where":"どこ",
    "when":"いつ",
    "how":"いくつ" 
}


def iter_files(path):
    """Walk through all files located under a root path."""
    if os.path.isfile(path):
        yield path
    elif os.path.isdir(path):
        for dirpath, _, filenames in os.walk(path):
            for f in filenames:
                yield os.path.join(dirpath, f)
    else:
        raise RuntimeError('Path %s is invalid' % path)

def make_split_data(data_set, split_nums=[0.9]):
    split_datasets = []
    start_idx = 0
    for split_num in split_nums:
        end_idx = int(split_num*len(data_set))
        split_datasets.append(data_set[start_idx:end_idx])
        start_idx = end_idx
    split_datasets.append(data_set[end_idx:])

    return split_datasets


def get_attribute_to_qa(path):
    '''
    属性名と[5W1H]の対応付けアノテーションを辞書型として取得
    '''
    d = {}
    with open(path, mode="r") as f:
        d = json.load(f)
    return d

def make_example(dataset, target_title, target_attr, original_question):
    # attrubuteが同じものをdatasetから抽出
    ex_dict = {key:value for key, value in dataset.items() if  target_attr in list(value.keys()) }
    
    # 元々のQuestionからハッシュ値を生成 → これをシード値として使用する．
    random.seed(original_question)
    sample_example = dict(random.sample(ex_dict.items(), 1))
    ex_title = list(sample_example.values())[0][target_attr][0]['title'] 
    ex_attr = list(sample_example.values())[0][target_attr][0]['attribute']
    ex_ans = list(sample_example.values())[0][target_attr][0]['text_offset']['text']
    h = hash(original_question+'1')
    while target_title == ex_title and target_attr == ex_attr:
        print('追加用Exampleと元々のQuestionが同じでした．再度サンプリングします')
        h += 1
        random.seed(h)
        sample_example = dict(random.sample(ex_dict.items(), 1))
        ex_title = list(sample_example.values())[0][target_attr][0]['title'] 
        ex_attr = list(sample_example.values())[0][target_attr][0]['attribute']
        ex_ans = list(sample_example.values())[0][target_attr][0]['text_offset']['text']
    example =  ex_title + "の" + ex_attr + "は" + ex_ans + "です。"
    return str(example)

def process(args, dataset, attributes, attribute_to_qa, question_type, train_num=None, dev_num=None, test_num=None):
    ## example追加用Dict
    if "example" in question_type :
        example_dataset = dataset
    
    ## (train_num + dev_num + test_num)の数だけ dataset からランダムサンプルする
    if (train_num is not None) and (dev_num is not None) and (test_num is not None):
        if (train_num + dev_num + test_num) > len(dataset.keys()):
            raise ValueError("ERROR : The number of samples exceeds the data set size. len(dataset)={}, The number of samples={}".format(dataset, (train_num + dev_num + test_num)))
        data_size = train_num + dev_num + test_num
        id_list = list(dataset.keys())
        id_list = random.sample(id_list,data_size)
        dataset = {key:value for key, value in dataset.items() if (key) in id_list}
    else:
        data_size = len(dataset.keys())
    
    squad_data = []
    
    for page_id, attrs in dataset.items():
        try:
            with Path(args.html_dir).joinpath(str(page_id)+'.html').open() as f:
                html_content = f.read()
        except:
            print('ERROR! No such file or directory:', Path(args.html_dir).joinpath(str(page_id)+'.html'))
            continue

        try:
            content, _ = html_util.replace_html_tag(html_content, html_tag=args.html_tag)
        except:
            print('ERROR! html_util')
            print(html_content)
            exit()

        line_len = []
        for line in content:
            if len(line) == 0 or (len(line) > 0 and line[-1] != '\n'):
                line_len.append(len(line)+1)
            else:
                line_len.append(len(line))

        flags = dict()
        paragraphs = []
        paragraph = ''
        found_answers = set()
        para_start_line_num = 0
        para_end_line_num = 0
        for line_num, line in enumerate(content):
            if not paragraph and len(line.replace(' ','').replace('\n','').strip()) == 0:
                continue
            if not paragraph:
                para_start_line_num = line_num
            paragraph += line
            if len(line) == 0 or (len(line) > 0 and line[-1] != '\n'):
                paragraph += '\n'

            #空テーブルContextを除外(突貫工事)
            if paragraph == "<table>                                             \n<tr> \n\n</td> \n\n</td></tr></table> \n":
                paragraph = ''
                continue

            if len(paragraph) > 0 and len(line) > 0 and line[-1] == '\n':
                para_end_line_num = line_num
                qas = []

                for q, dist_lines in attrs.items():

                    q_id = str(page_id) + '_' + str(len(paragraphs)) + '_' + str(attributes.index(q))

                    if q in FLAG_ATTRS:
                        flags[q] = True
                        for ans in dist_lines:
                            ENE = ans['ENE']
                            title = ans['title']

                    else:
                        answers = []
                        for ans in dist_lines:
                            ENE = ans['ENE']
                            title = ans['title']
                            ans = ans['html_offset']

                            if para_start_line_num <= ans['start']['line_id'] and para_end_line_num >= ans['end']['line_id']:
                                start_section_idx = 0
                                end_section_idx = 0

                                if para_start_line_num == para_end_line_num:
                                    answer_start_position = ans['start']['offset'] + start_section_idx
                                    answer_end_position = ans['end']['offset'] + end_section_idx
                                else:
                                    if para_start_line_num < ans['start']['line_id']:
                                        answer_start_position = sum(line_len[para_start_line_num:ans['start']['line_id']]) + ans['start']['offset'] + start_section_idx
                                    else:
                                        answer_start_position = ans['start']['offset']  + start_section_idx
                                    if para_start_line_num < ans['end']['line_id']:
                                        answer_end_position = sum(line_len[para_start_line_num:ans['end']['line_id']]) + ans['end']['offset'] + end_section_idx
                                    else:
                                        answer_end_position = ans['end']['offset'] + end_section_idx
                                found_answers.add('-'.join([str(a) for a in [ans['start']['line_id'],ans['start']['offset'],ans['end']['line_id'],ans['end']['offset']]]))
                                if len(paragraph[answer_start_position:answer_end_position].replace(' ','').replace('\n','').strip()) == 0:
                                    print('WARNING! answer text is N/A', q, ans, paragraph[answer_start_position:answer_end_position], title, page_id)
                                    continue
                                answers.append({"answer_start": answer_start_position, "answer_end": answer_end_position, "text": paragraph[answer_start_position:answer_end_position]})
                        
                        
                        try:
                            W5H1 = attribute_to_qa_LIST[attribute_to_qa[args.category][q]]
                        except Exception as e:
                            print(e)
                            print("Error! : can not read 5W1H")
                            print("category : {}     attribute : {} ".format(args.category, q))
                            exit()
                        ## create question 
                        try:
                            if set(["attribute"]) == set(question_type) :
                                question = q 
                            elif set(["title", "attribute"]) == set(question_type) :
                                question = title + "の" + q 
                            elif set(["attribute", "question"]) == set(question_type) :
                                question = q + "は?"
                            elif set(["title", "attribute", "question"]) == set(question_type) :
                                question = title + "の" + q + "は?"
                            elif set(["attribute","5W1H", "question" ]) == set(question_type) :
                                question = q + "は" + W5H1 + "ですか?"
                            elif set(["title", "attribute", "5W1H", "question"]) == set(question_type) :
                                question = title + "の" + q + "は" + W5H1 + "ですか?"
                            elif set(["title", "attribute", "5W1H", "question", "example"]) == set(question_type) :
                                original_question = title + "の" + q + "は" + W5H1 + "ですか?"
                                example = make_example(example_dataset, title, q, original_question)
                                question = example + title + "の" + q + "は" + W5H1 + "ですか?"
                            else:
                                raise Exception
                        except Exception as e:
                            print(e)
                            print("Error! : can not matching question_type ")
                            print("question_type : {}".format(question_type))
                            exit()

                        attribute = q 
                        qas.append({"question": question, "id": q_id, "attribute":attribute, "answers": answers})

                for q in set(attributes) - set(attrs.keys()):
                    if q in FLAG_ATTRS:
                        flags[q] = False
                    else:
    
                        try:
                            W5H1 = attribute_to_qa_LIST[attribute_to_qa[args.category][q]]
                        except Exception as e:
                            print(e)
                            print("Error! : can not read 5W1H")
                            exit()
                        
                        ## create question 
                        try:
                            if set(["attribute"]) == set(question_type) :
                                question = q 
                            elif set(["title", "attribute"]) == set(question_type) :
                                question = title + "の" + q 
                            elif set(["attribute", "question"]) == set(question_type) :
                                question = q + "は?"
                            elif set(["title", "attribute", "question"]) == set(question_type) :
                                question = title + "の" + q + "は?"
                            elif set(["attribute","5W1H", "question" ]) == set(question_type) :
                                question = q + "は" + W5H1 + "ですか?"
                            elif set(["title", "attribute", "5W1H", "question"]) == set(question_type) :
                                question = title + "の" + q + "は" + W5H1 + "ですか?"
                            elif set(["title", "attribute", "5W1H", "question", "example"]) == set(question_type) :
                                original_question = title + "の" + q + "は" + W5H1 + "ですか?"
                                example = make_example(example_dataset, title, q, original_question)
                                question = example + title + "の" + q + "は" + W5H1 + "ですか?"
                            else:
                                raise Exception
                        except Exception as e:
                            print(e)
                            print("Error! : can not matching question_type ")
                            print("question_type : {}".format(question_type))
                            exit()

                        attribute = q
                        qas.append({"question": question, "id": str(page_id) + '_' + str(len(paragraphs)) + '_' + str(attributes.index(q)), "attribute":attribute, "answers": []})
                paragraphs.append({"context": paragraph, "start_line":para_start_line_num, "end_line":para_end_line_num, "qas": qas})
                paragraph = ''

        try:
            if flags.keys():
                squad_json = {"title": title, 'WikipediaID': page_id, "ENE":ENE, "paragraphs": paragraphs, "flags": flags}
            else:
                squad_json = {"title": title, 'WikipediaID': page_id, "ENE":ENE, "paragraphs": paragraphs}
        except Exception as e:
            print(e)
            print('ERROR', page_id, line_num, line)
            print(paragraphs)
            exit()

        squad_data.append(squad_json)
        print('-'*5, str(len(squad_data)) + '/' + str(data_size), str(page_id), title, '-'*5)

    return squad_data


def process_formal(args, attribute_to_qa, question_type):
    
    ENE = attr_list.get_ENE(args.category)

    attr_names = attr_list.get_attr_list(category=args.category)
    attributes = {att:[] for att in attr_names}
    squad_data = []

    files = [f for f in iter_files(Path(args.html_dir))]
    data_size = len(files)
    if "example" in question_type :
        example_dataset = files

    for i, file in enumerate(files):
        page_id = Path(file).stem
        with open(file) as f:
            html_content = f.read()
        content, title = html_util.replace_html_tag(html_content, html_tag=args.html_tag)

        print('-'*5, str(i) + '/' + str(data_size), str(page_id), title, '-'*5)

        paragraphs = []
        paragraph = ''
        found_answers = set()
        para_start_line_num = 0
        para_end_line_num = 0
        for line_num, line in enumerate(content):
            if not paragraph and len(line.replace(' ','').replace('\n','').strip()) == 0:
                continue
            if not paragraph:
                para_start_line_num = line_num
            paragraph += line
            if len(line) == 0 or (len(line) > 0 and line[-1] != '\n'):
                paragraph += '\n'

            if len(paragraph) > 0 and len(line) > 0 and line[-1] == '\n':
                para_end_line_num = line_num
                q_idx = 0
                qas = []

                for k,v in attributes.items():
                    q = k

                    q_idx += 1
                    q_id = str(page_id) + '_' + str(len(paragraphs)) + '_' + str(q_idx)
                    answers = []
                    
                    try:
                        W5H1 = attribute_to_qa_LIST[attribute_to_qa[args.category][q]]
                    except Exception as e:
                        print(e)
                        print("Error! : can not read 5W1H")
                        exit()
                    
                    ## create question 
                    try:
                        if set(["attribute"]) == set(question_type) :
                            question = q 
                        elif set(["title", "attribute"]) == set(question_type) :
                            question = title + "の" + q 
                        elif set(["attribute", "question"]) == set(question_type) :
                            question = q + "は?"
                        elif set(["title", "attribute", "question"]) == set(question_type) :
                            question = title + "の" + q + "は?"
                        elif set(["attribute","5W1H", "question" ]) == set(question_type) :
                            question = q + "は" + W5H1 + "ですか?"
                        elif set(["title", "attribute", "5W1H", "question"]) == set(question_type) :
                            question = title + "の" + q + "は" + W5H1 + "ですか?"
                        elif set(["title", "attribute", "5W1H", "question", "example"]) == set(question_type) :
                            original_question = title + "の" + q + "は" + W5H1 + "ですか?"
                            example = make_example(example_dataset, title, q, original_question)
                            question = example + title + "の" + q + "は" + W5H1 + "ですか?"
                        else:
                            raise Exception
                    except Exception as e:
                        print(e)
                        print("Error! : can not matching question_type ")
                        print("question_type : {}".format(question_type))
                        exit()
                    
                    attribute = q
                    qas.append({"answers": answers, "question": question, "attribute":attribute ,"id": q_id})

                paragraphs.append({"context": paragraph, "qas": qas, "start_line":para_start_line_num, "end_line":para_end_line_num})
                paragraph = ''

        squad_json = {"title": title, 'WikipediaID': page_id, "ENE":ENE, "paragraphs": paragraphs}
        #print(squad_json)
        squad_data.append(squad_json)

    return squad_data


def set_seed(args):
    random.seed(args.seed)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--category', type=str, default=None,
                    help='Shinra category')
    parser.add_argument('--train_num', type=int, default=None,
                    help='Number of train data')
    parser.add_argument('--dev_num', type=int, default=None,
                    help='Number of dev data')
    parser.add_argument('--test_num', type=int, default=None,
                    help='Number of test data')
    parser.add_argument('--input', type=str, default=None)
    parser.add_argument('--output', type=str, default=None)
    parser.add_argument('--question_type', type=str, default="attribute",
                        help='setting question(=query) type.\n \
                            You can use any combination of the following question types.\n\
                            question_type= attribute, title, question, 5W1H\
                            For example, question_type="attribute title question" , \
                            then　question = "シャネルの本拠地は？"')
    parser.add_argument('--attribute_to_qa', type=str, default=None)
    parser.add_argument('--split_dev', type=float, default=0.85,
                        help='start point of dev data')
    parser.add_argument('--split_test', type=float, default=0.90,
                        help='start point of test data')
    parser.add_argument('--formal', action='store_true',
                        help='formal mode')
    parser.add_argument('--html_dir', type=str, default=None)
    parser.add_argument('--html_tag', action='store_true',
                        help='')
    parser.add_argument("--seed", default=42, type=int)
    args = parser.parse_args()
    set_seed(args)

    answer = get_annotation(args.input)
    attribute_to_qa = get_attribute_to_qa(args.attribute_to_qa) #属性名と5W1Hの対応付けデータ
    ene = get_ene(answer)
    question_type=args.question_type.split(',')
    id_dict, html, plain, attributes = liner2dict(answer, ene)
    print('attributes:', attributes)

    squad_data = process(args, id_dict, attributes, attribute_to_qa, question_type, args.train_num, args.dev_num, args.test_num)
    if (args.train_num is not None) and (args.dev_num is not None) and (args.test_num is not None):
        split_dev = (args.train_num) / (args.train_num + args.dev_num + args.test_num)
        split_test = (args.train_num + args.dev_num) / (args.train_num + args.dev_num + args.test_num)
    else:
        split_dev = args.split_dev
        split_test = args.split_test

    split_dataset = make_split_data(squad_data, split_nums=[split_dev, split_test])

    with open(args.output.replace('.json', '-train.json'), 'w') as f:
        f.write(json.dumps({"data": split_dataset[0]}, ensure_ascii=False))

    with open(args.output.replace('.json', '-dev.json'), 'w') as f:
        f.write(json.dumps({"data": split_dataset[1]}, ensure_ascii=False))

    if not args.formal:
        with open(args.output.replace('.json', '-test.json'), 'w') as f:
            f.write(json.dumps({"data": split_dataset[2]}, ensure_ascii=False))

        target_ids = []
        for entry in split_dataset[2]:
            target_ids.append(entry["WikipediaID"])

        if target_ids:
            with open(args.output.replace('.json', '-test-id.txt').replace('squad_', ''), 'w') as f:
                f.write('\n'.join(target_ids))

main()
