# Indri OSIRRC Docker Image

[**Claudia Hauff**](https://github.com/chauff)

This is the docker image for [Indri v5.13](https://sourceforge.net/projects/lemur/) conforming to the [OSIRRC jig](https://github.com/osirrc/jig/) for the [Open-Source IR Replicability Challenge (OSIRRC) at SIGIR 2019](https://osirrc.github.io/osirrc2019/).
This image is has been tested with the jig at commit [ e26b16c](https://github.com/osirrc/jig/commit/e26b16c500bd575cbe588f718b80af6d331fe7fb) (June 14, 2019).

+ Supported test collections: `robust04`
+ Supported hooks: `index`, `search`

## Quick Start

The following `jig` command can be used to index TREC disks 4/5 for `robust04`:

```
python3 run.py prepare \
  --repo osirrc2019/indri \
  --collections robust04=/path/to/disk45=trectext
```
The created index is stemmed (Krovetz), with stopwords removed. 

The following `jig` command can be used to perform a retrieval run on the collection with the `robust04` test collection:

```
python3 run.py search \
  --repo osirrc2019/indri \
  --output out/indri \
  --qrels qrels/qrels.robust04.txt \
  --topic topics/topics.robust04.txt \
  --collection robust04 \ 
  --top_k 1000" \
  --opts out_file_name="robust.dir1000" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="0"
```
The option `--opts` has a `rule` entry to determine the retrieval method, a `topic_type` entry to determine the TREC topic type (either `title`, `desc` or `narr`) and a `use_prf` entry to determine the usage of pseudo-relevance feedback (`"1"` to use PRF, anything else to not use it). 

Valid  retrieval `rule` entries can be found [in the Indri documentation](https://lemurproject.org/doxygen/lemur/html/IndriRunQuery.html). Importantly, the `tfidf` and `okapi` methods also work in the `rule` entry (i.e. no separate *baseline* entry is necessary). 

While a retrieval rule can be specified, for PRF this option is not available at the moment (check [searchRobust04.sh](searchRobust04.sh) to make changes), instead a set of default settings are used: 50 feedback documents, 25 feedback terms and equal weighting between the original and expanded query.

## Expected Results

The following table contains examples of `--opts` and the expected retrieval effectiveness in MAP and precision @30.

### robust04

|                                                                                                                      | MAP    | P30    |
|----------------------------------------------------------------------------------------------------------------------|--------|--------|
| `--opts out_file_name="robust.dir1000.title" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="0"`         | 0.2477 | 0.3084 |
| `--opts out_file_name="robust.dir1000.title" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="1"`         | 0.2784 | 0.3229 |
| `--opts out_file_name="robust.jm0.5.title" rule="method:linear,collectionLambda:0.5" topic_type="title" use_prf="0"` | 0.2220 | 0.2827 |
| `--opts out_file_name="robust.bm25.title" rule="okapi,k1:1.2,b:0.75,k3:7" topic_type="title" use_prf="0"`            | 0.2316 | 0.2977 |
| `--opts out_file_name="robust.bm25.desc" rule="okapi" topic_type="desc" use_prf="0"`                                 | 0.2676 | 0.3265 |

## Implementation

The following is a quick breakdown of what happens in each of the scripts in this repo.

### Dockerfile

The `Dockerfile` installs dependencies (`python3`, etc.), copies scripts to the root dir, and sets the working dir to `/work`. It also installs Indri.

### index

The `Robust04` corpus is difficult to handle for Indri: the original version is `.z` compressed, a compression Indri cannot handle. And thus, `indexRobust04.sh` first uncompresses the collection, filters out undesired folders (such as `cr`), downloads Lemur's stopword list, creates a parameter file for indexing and finally calls Indri's `IndriBuildIndex`.

### search

The `Robust04` topics are in "classic" TREC format, a format Indri cannot handle. Thus, first the TREC topic file has to be converted into a format Indri can parse (done in [topicFormatting.pl](topicFormatting.pl)). Note: different retrieval methods require differently formatted Indri topic files. A parameter file is created and finally `IndriRunQuery` is executed.

## Reviews

+ Documentation not yet reviewed