local train_size = 129974;
local batch_size = 8;
local grad_accumulate = 4;
local num_epochs = 9;
local bert_model = "bert-base-uncased";
local seed = 18551;

{

    "numpy_seed":seed,
    "pytorch_seed":seed,

    "dataset_reader": {
        "type": "mac_bert_no_coverage",
        "tokenizer": {
            "type": "bert-multinli",
            "pretrained_model": bert_model
        },
        "token_indexers": {
            "tokens": {
                "type": "bert-multinli",
                "pretrained_model": bert_model
            }
        },
        "max_pieces":64
    },

    "train_data_path": "/home/amitra7/multihop/mcq_abductive_train.jsonl",
    "validation_data_path": "/home/amitra7/multihop/mcq_abductive_dev.jsonl",
    "model": {
        "type": "mac_bert_no_coverage",
        "bert_model": bert_model,
        "initializer": [
            [".*linear_layers.*weight", {"type": "xavier_normal"}]
        ],
        "dropout": 0.2
    },
    "iterator": {
        "type": "basic",
        "batch_size": batch_size
    },
   "trainer": {

    "optimizer": {
      "type": "bert_adam",
      "weight_decay_rate": 0.009,
      "parameter_groups": [[["bias", "gamma", "beta"], {"weight_decay_rate": 0}]],
      "lr": 2e-5
    },
    "learning_rate_scheduler": {
      "type": "slanted_triangular",
      "num_epochs": num_epochs,
      "cut_frac": 0.2,
      "num_steps_per_epoch": std.ceil(train_size / batch_size),
    },
    "validation_metric": "+accuracy",
    "num_serialized_models_to_keep": 2,
    "should_log_learning_rate": true,
    "num_epochs": num_epochs,
    "grad_accumulate_epochs": grad_accumulate,
    "cuda_device": 0
  }
}