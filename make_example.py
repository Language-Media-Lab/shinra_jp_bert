#!/usr/bin/env python3

import argparse
import json
import csv
from pathlib import Path
import os, os.path
from shinra_jp_scorer.scoring import liner2dict, get_annotation, get_ene

import random
from collections import defaultdict

import io,sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

FLAG_ATTRS = ['総称']

def get_train_WikiID(path, category):
    """
    train dataのWikiID(記事ID)をリストで返す
    """
    target = []
    with open(str(path)+"/"+str(category)+"-train-id.txt", "r", encoding = "utf_8") as f:
        reader = csv.reader(f)
        for row in reader:
            target += row
    return target

def get_query(target_attr, target_example, get_num):
    """
    ExampleリストからQuery(str)を作って返す
    """
    if get_num > 3 and target_attr in ["地名の謂れ","製造方法","名前の謂れ"]: ##Exampleが3つ以上の場合，["地名の謂れ","製造方法","名前の謂れ"]は長すぎてしまうので，3つ以内とする．
        get_num = 3
    if len(target_example) < get_num: 
        get_num = len(target_example)
    query = "例えば、"

    for i in range(get_num):
        query = query + target_example[i]['text'] + "、"
    query = query + "などです。"
    return query

def get_example_list(dataset, target_attr, seed, get_num, train_WikiID):
    """
    Exampleのリストをget_numで指定された個数で取得する．
    [{"page_id" : 1, "title":"testTitle1",  "text":"testAns1" }, {"page_id" : 2, "title":"testTitle2",  "text":"testAns2" }, ...]
    """
    
    example_subset = []
    for page_id, attrs in dataset.items():
        if target_attr in  list(attrs.keys()) and page_id in train_WikiID:
            d = {"page_id" : page_id, "title":attrs[target_attr][0]['title'],  "text":attrs[target_attr][0]['text_offset']['text'] }
            example_subset.append(d)
    random.seed(seed)
    if len(example_subset) < get_num: #get_numより数が少ない場合
        example_dict = random.sample(example_subset,len(example_subset)) 
    else:
        example_dict = random.sample(example_subset,get_num)
    return example_dict 



def process(dataset, attributes, seed, get_num, train_WikiID):
    """
    example_dict_c と example_query_c　を返します．
    example_dict_c：
        カテゴリが持つタイトルと属性値をシード値によってランダムサンプルし，
        属性値ごとのタイトル，記事ID，Ansをリストで複数取得後，Dictにまとめて返します．
        例：{
            "別名" : [{"page_id" : 1, "title":"testTitle1",  "text":"testAns1" }, {"page_id" : 2, "title":"testTitle2",  "text":"testAns2" }, ...]
            ...
            }
    example_query_c：  
        example_dict_cから生成されたクエリをValueとして持つDictを返します．
        例：{
            "別名" : "例えば、testAns1、testAns2などです。"
            ...
            }
    """
    examples = defaultdict(list)
    query = defaultdict(list)
    for attr in attributes:
        examples[attr] = get_example_list(dataset, attr, seed, get_num, train_WikiID)
        query[attr] = get_query(attr, examples[attr], get_num)
    return examples, query

def set_seed(args):
    random.seed(args.seed)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--category', type=str, default=None,
                    help='Shinra category')
    parser.add_argument('--input', type=str, default=None)
    parser.add_argument('--wikiID_dir', type=str, default=None)
    parser.add_argument('--output_dir', type=str, default=None)
    parser.add_argument("--seed", default=42, type=int)
    parser.add_argument("--example_num", default=3, type=int)
    parser.add_argument("--output_file_name", default=None, type=str)
    args = parser.parse_args()
    set_seed(args)
    categories=["Person", "Company", "City", "Airport", "Compound"]

    example_dict_all = defaultdict(list)
    example_query_all = defaultdict(list)
    for c in categories:
        print(c)
        train_WikiID = get_train_WikiID(args.wikiID_dir, c)
        answer = get_annotation(args.input+'/'+c+'_dist.json')
        ene = get_ene(answer)
        id_dict, html, plain, attributes = liner2dict(answer, ene)
        example_dict_c, example_query_c = process(id_dict, attributes, args.seed, args.example_num, train_WikiID)
        example_dict_all[c] = example_dict_c
        example_query_all[c] = example_query_c

    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    if args.output_file_name is not None:
        output_file_name = args.output_file_name
    else:
        output_file_name = 'seed'+str(args.seed)+'_num'+str(args.example_num)
    
    with open(args.output_dir+'/examples_' + output_file_name + '.json', 'w') as f:
        f.write(json.dumps(example_dict_all, ensure_ascii=False, indent=4))
    with open(args.output_dir+'/examples_query_' + output_file_name + '.json', 'w') as f:
        f.write(json.dumps(example_query_all, ensure_ascii=False, indent=4))

main()
