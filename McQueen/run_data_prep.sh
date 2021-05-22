#!/usr/bin/env bash

#elasticsearch-1.4.2/bin/elasticsearch
 
python3 preprare_dataset.py data.jsonl

python3 ir_from_aristo_lemmatized.py dev_ir_lemma.tsv

python3 merge_ir.py typed
python3 clean_dataset.py data_typed.jsonl

                        
                                            

