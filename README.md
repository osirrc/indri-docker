# OSIRRC Docker Image for Indri
[![Generic badge](https://img.shields.io/badge/DockerHub-go%21-yellow.svg)](https://hub.docker.com/r/osirrc2019/indri)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3247067.svg)](https://doi.org/10.5281/zenodo.3247067)

[**Claudia Hauff**](https://github.com/chauff)

This is the docker image for [Indri v5.13](https://sourceforge.net/projects/lemur/) conforming to the [OSIRRC jig](https://github.com/osirrc/jig/) for the [Open-Source IR Replicability Challenge (OSIRRC) at SIGIR 2019](https://osirrc.github.io/osirrc2019/).
This image is available on [Docker Hub](https://hub.docker.com/r/osirrc2019/anserini).
The [OSIRRC 2019 image library](https://github.com/osirrc/osirrc2019-library) contains a log of successful executions of this image.

+ Supported test collections: `robust04`
+ Supported hooks: `index`, `search`

## Quick Start

First, clone the [`jig`](https://github.com/osirrc/jig) and follow its setup instructions - in particular, do not forget to also clone and install `trec_eval` inside the `jig` directory!

Once that is done, the following `jig` command can be used to index TREC disks 4/5 for `robust04`:

```
python3 run.py prepare \
  --repo osirrc2019/indri \
  --tag v0.1.0 \
  --collections robust04=/path/to/disk45=trectext
```
The created index is stemmed (Krovetz), with stopwords removed. The `manifest` file of the Indri index (printed to the terminal) should look as follows:

```
::::::::::::::
/robust04/index/1/manifest
::::::::::::::
<parameters>
	<code-build-date>Jun 15 2019</code-build-date>
	<corpus>
		<document-base>1</document-base>
		<frequent-terms>10886</frequent-terms>
		<maximum-document>528156</maximum-document>
		<total-documents>528155</total-documents>
		<total-terms>253367449</total-terms>
		<unique-terms>664438</unique-terms>
	</corpus>
	<fields></fields>
	<indri-distribution>Indri release 5.11</indri-distribution>
	<type>DiskIndex</type>
</parameters>
```

The following `jig` command can be used to perform a retrieval run on the collection with the `robust04` test collection:

```
python3 run.py search \
  --repo osirrc2019/indri \
  --tag v0.1.0 \
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
| `--opts out_file_name="robust.dir1000.title" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="0"`         | 0.2499 | 0.3100 |
| `--opts out_file_name="robust.dir1000.title.prf" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="1"`         | 0.2812 | 0.3248 |
| `--opts out_file_name="robust.jm0.5.title" rule="method:linear,collectionLambda:0.5" topic_type="title" use_prf="0"` | 0.2242 | 0.2839 |
| `--opts out_file_name="robust.bm25.title" rule="okapi,k1:1.2,b:0.75,k3:7" topic_type="title" use_prf="0"`            | 0.2338 | 0.2995 |
| `--opts out_file_name="robust.bm25.desc" rule="okapi" topic_type="desc" use_prf="0"`                                 | 0.2702 | 0.3274 |

## Implementation

The following is a quick breakdown of what happens in each of the scripts in this repo.

### Dockerfile

The `Dockerfile` installs dependencies (`python3`, etc.), copies scripts to the root dir, and sets the working dir to `/work`. It also installs Indri.

### index

The `Robust04` corpus is difficult to handle for Indri: the original version is `.z` compressed, a compression Indri cannot handle. And thus, `indexRobust04.sh` first uncompresses the collection, filters out undesired folders (such as `cr`), downloads Lemur's stopword list, creates a parameter file for indexing and finally calls Indri's `IndriBuildIndex`.

### search

The `Robust04` topics are in "classic" TREC format, a format Indri cannot handle. Thus, first the TREC topic file has to be converted into a format Indri can parse (done in [topicFormatting.pl](topicFormatting.pl)). Note: different retrieval methods require differently formatted Indri topic files. A parameter file is created and finally `IndriRunQuery` is executed.

## Reviews

+ Documentation reviewed at commit [`b10184e`](https://github.com/osirrc/indri-docker/commit/0393a0419a89e88ae13b9a03094956bfdb10184e) (2019-06-16) by [r-clancy](https://github.com/r-clancy/).
