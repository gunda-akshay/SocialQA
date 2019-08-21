# coding=utf-8
# Copyright 2018 The Google AI Language Team Authors and The HuggingFace Inc. team.
# Copyright (c) 2018, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""BERT finetuning runner."""

from __future__ import absolute_import

import logging
import torch
from torch import nn


from pytorch_transformers.modeling_bert import BertPreTrainedModel, BertModel
from torch.nn import CrossEntropyLoss

logging.basicConfig(format='%(asctime)s - %(levelname)s - %(name)s -   %(message)s',
                    datefmt='%m/%d/%Y %H:%M:%S',
                    level=logging.INFO)
logger = logging.getLogger(__name__)


class BertMCQWeightedSum(BertPreTrainedModel):
    def __init__(self, config, dropout, tie_weights):
        super(BertMCQWeightedSum, self).__init__(config)
        self.bert_model = BertModel(config)
        self._dropout = nn.Dropout(dropout)
        self._classification_layer = nn.Linear(config.hidden_size, 1)
        if tie_weights is True:
            self._weight_layer = self._classification_layer
        else:
            self._weight_layer = nn.Linear(config.hidden_size, 1)
        self.apply(self.init_weights)

    def forward(self,  # type: ignore
                input_ids,
                token_type_ids,
                input_mask,
                labels = None):

        debug = False

        # shape: batch_size*num_choices*max_premise_perchoice, max_len
        flat_input_ids = input_ids.view(-1, input_ids.size(-1))
        flat_token_type_ids = token_type_ids.view(-1, token_type_ids.size(-1))
        flat_attention_mask = input_mask.view(-1, input_mask.size(-1))

        # shape: batch_size*num_choices*max_premise_perchoice, hidden_dim
        _, pooled_ph = self.bert_model(input_ids=flat_input_ids,
                                       token_type_ids=flat_token_type_ids,
                                       attention_mask=flat_attention_mask)

        if debug:
            print(f"input_ids.size() = {input_ids.size()}")
            print(f"token_type_ids.size() = {token_type_ids.size()}")
            print(f"pooled_ph.size() = {pooled_ph.size()}")

        pooled_ph = self._dropout(pooled_ph)

        # apply weighting layer
        weights = self._weight_layer(pooled_ph)

        # multiply each element by the corresponding scores
        weighted_ph = pooled_ph * weights.unsqueeze(1)

        #reshape: batch*num_choices, number_of_premises, hidden_dim
        weighted_ph = weighted_ph.view(-1,input_ids.size(2),pooled_ph.size(1))
        weighted_ph = torch.sum(weighted_ph,1)

        #apply classification layer
        logits = self._classification_layer(weighted_ph)

        if debug:
            print(f"logits.size() = {logits.size()}")

        # shape: batch_size,num_choices
        reshaped_logits = logits.view(-1, input_ids.size(1))
        if debug:
            print(f"reshaped_logits = {reshaped_logits}")

        probs = torch.nn.functional.softmax(reshaped_logits, dim=-1)
        outputs = (reshaped_logits, probs)

        if labels is not None:
            loss_fct = CrossEntropyLoss()
            loss = loss_fct(reshaped_logits, labels)
            outputs = (loss,) + outputs

        return outputs  # (loss, reshaped_logits, prob)



