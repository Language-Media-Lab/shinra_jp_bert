#!/usr/bin/env python3

import argparse
import json
import csv
from pathlib import Path
import os, os.path

import random
from collections import defaultdict

import io,sys
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

FLAG_ATTRS = ['総称']

def get_train_WikiID(dir_path, category):
    """
    train dataのWikiID(記事ID)をリストで返す
    """
    target = []
    with open(str(dir_path)+"/"+str(category)+"-train-id.txt", "r", encoding = "utf_8") as f:
        reader = csv.reader(f)
        for row in reader:
            target += row
    return target

def reduce_train_dataset(args, train_WikiID, file_path=None):
    """
    データセットのデータ数を減らす．
    データセットから，data_sizeの数だけ残して辞書型を返す
    """
    print("file_path  :  "+file_path)
    train_data = {}
    with open(file_path, mode="r") as f:
        train_data = json.load(f)
    reduced_train_data = []

    for data in train_data['data']:
        if data["WikipediaID"] in train_WikiID:
            reduced_train_data.append(data)

    return {"data": reduced_train_data}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--category', type=str, default=None,
                    help='Shinra category')
    parser.add_argument('--work_dir', type=str, default=None)
    parser.add_argument('--data_size', type=int, default=None)
    parser.add_argument("--seed", default=42, type=int)
    parser.add_argument('--wikiID_dir', type=str, default=None)
    args = parser.parse_args()

    train_wikiID = get_train_WikiID(args.wikiID_dir, args.category)
    ## train_wikiIDをseed固定してシャッフルする．
    random.seed(args.seed)
    random.shuffle(train_wikiID)
    reduced_train_wikiID = train_wikiID[:args.data_size]

    reduced_train_data = reduce_train_dataset(args, reduced_train_wikiID, file_path='{}/squad_{}-train.json'.format(args.work_dir, args.category))

    ## train dataの上書き
    with open('{}/squad_{}-train.json'.format(args.work_dir, args.category), 'w') as f:
        f.write(json.dumps(reduced_train_data, ensure_ascii=False))

    ## train WikipediaIDの上書き
    with open("{}/{}-train-id.txt".format(args.wikiID_dir, args.category), 'w') as f:
        f.write('\n'.join(reduced_train_wikiID))


main()
