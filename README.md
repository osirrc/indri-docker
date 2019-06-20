# Indri OSIRRC Docker Image

[**Claudia Hauff**](https://github.com/chauff)

This is the docker image for [Indri v5.13](https://sourceforge.net/projects/lemur/) conforming to the [OSIRRC jig](https://github.com/osirrc/jig/) for the [Open-Source IR Replicability Challenge (OSIRRC) at SIGIR 2019](https://osirrc.github.io/osirrc2019/).
This image is has been tested with the jig at commit [ e26b16c](https://github.com/osirrc/jig/commit/e26b16c500bd575cbe588f718b80af6d331fe7fb) (June 14, 2019).

+ Supported test collections: `robust04`, `gov2`
+ Supported hooks: `index`, `search`

## Quick Start

First, clone the [`jig`](https://github.com/osirrc/jig) and follow its setup instructions - in particular, do not forget to also clone and install `trec_eval` inside the `jig` directory!

### Indexing a collection

Once that is done, the following `jig` command can be used to index TREC disks 4/5 for `robust04` (analogous command for the `gov2` corpus):

```
python3 run.py prepare \
  --repo osirrc2019/indri \
  --collections robust04=/path/to/disk45=trectext
```

For `robust04`, the `manifest` file of the Indri index (printed to the terminal) should look as follows:

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

For `gov2`, the `manifest` file looks like this:

::::::::::::::
/gov2/index/8/manifest
::::::::::::::
<parameters>
	<code-build-date>Jun 15 2019</code-build-date>
	<corpus>
		<document-base>1</document-base>
		<frequent-terms>21590</frequent-terms>
		<maximum-document>25205180</maximum-document>
		<total-documents>25205179</total-documents>
		<total-terms>1498525044</total-terms>
		<unique-terms>3019667</unique-terms>
	</corpus>
	<fields></fields>
	<indri-distribution>Indri release 5.11</indri-distribution>
	<type>DiskIndex</type>
</parameters>


### Searching a collection

The following `jig` command can be used to perform a retrieval run on the collection with the `robust04` test collection:

```
python3 run.py search \
  --repo osirrc2019/indri \
  --output out/indri \
  --qrels qrels/qrels.robust04.txt \
  --topic topics/topics.robust04.txt \
  --collection robust04 \ 
  --top_k 1000 \
  --opts out_file_name="robust.dir1000" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="0"
```

For `gov2`, use the following command:
```
python3 run.py search \
  --repo osirrc2019/indri \
  --output out/indri \
  --qrels qrels/qrels.701-850.txt \
  --topic topics/topics.701-850.txt \
  --collection gov2 \ 
  --top_k 1000 \
  --opts out_file_name="gov2.dir1000" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="0"
```

The option `--opts` has a `rule` entry to determine the retrieval method, a `topic_type` entry to determine the TREC topic type (either `title`, `desc` or `narr` or a combination, e.g. `title+desc`), a `use_prf` entry to determine the usage of pseudo-relevance feedback (`"1"` to use PRF, anything else to not use it) and a `sd` entry to switch on (`"1"`) or off the sequence dependency model (`sd` will have no effect on `tfidf` or `okapi`). Both `sd` and `use_prf` are optional parameters; if they are not provided, they are by default switched off.

Valid  retrieval `rule` entries can be found [in the Indri documentation](https://lemurproject.org/doxygen/lemur/html/IndriRunQuery.html). Importantly, the `tfidf` and `okapi` methods also work in the `rule` entry (i.e. no separate *baseline* entry is necessary). Note that there are default parameter settings for all of the retrieval rules - if only the name, but no further information is provided, the defaults are used.

While a retrieval rule can be specified, for PRF this option is not available at the moment (check [searchRobust04.sh](searchRobust04.sh) to make changes), instead a set of default settings are used: 50 feedback documents, 25 feedback terms and equal weighting between the original and expanded query.

## Setup Details

- The created index is stemmed (Krovetz), with stopwords removed. The [Lemur project stopword list](http://www.lemurproject.org/stopwords/stoplist.dft) was used; it contains 418 stopwords.
- The pseudo-relevance feedback setting is hardcoded in [search.sh](search.sh): 50 `fbDocs`, 25 `fbTerms`, 0.5 `fbOrigWeight`.
- The sequential dependency model setting is hardcoded in [topicFormatting.pl](topicFormatting.pl): 0.9 original query, 0.05 bigram, 0.05 unordered window.
- Only standard stopword removal is applied to the topics; this means that in the TREC description and TREC narrative phrases like *Find relevant documents about* or *Relevant are documents that ...* **remains** in the topic after processing. 

## Expected Results

The following table contains examples of `--opts` and the expected retrieval effectiveness in MAP, Precision@30/@10 and NDCG@20. These metrics may seem arbitrary; in fact, they were chosen to make---at least on paper---comparisons to published works on the same corpus.

### `robust04`

The results below are computed based on the 249 topics of `robust04`.

|       | MAP    | P@30    | P@10 | NDCG@20    |
|----------------------------------------------------------------------------------------------------------------------|--------|--------|--------|--------|
| :one: `--opts out_file_name="robust.dir1000.title" rule="method:dirichlet,mu:1000" topic_type="title"`         | 0.2499 | 0.3100 | 0.4253 | 0.4201 | 
| :two: `--opts out_file_name="robust.dir1000.title.sd" rule="method:dirichlet,mu:1000" topic_type="title" sd="1"`         | 0.2547 | 0.3146 | 0.4329 | 0.4232 |
| :three: `--opts out_file_name="robust.dir1000.title.prf" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="1"`         | 0.2812 | 0.3248 | 0.4386 | 0.4276 |
| :four: `--opts out_file_name="robust.dir1000.title.prf.sd" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="1" sd="1"`  | 0.2855 | 0.3295 | 0.4474 | 0.4298 |
| :five: `--opts out_file_name="robust.jm0.5.title" rule="method:linear,collectionLambda:0.5" topic_type="title"` | 0.2242 | 0.2839 | 0.3819 | 0.3689 |
| :six: `--opts out_file_name="robust.bm25.title" rule="okapi,k1:1.2,b:0.75" topic_type="title"`            | 0.2338 | 0.2995 | 0.4181 | 0.4041 |
| :seven: `--opts out_file_name="robust.bm25.title.prf" rule="okapi,k1:1.2,b:0.75" topic_type="title" use_prf="1"`            | 0.2563 | 0.3041 | 0.4012 | 0.3995 |
| :eight: `--opts out_file_name="robust.bm25.title+desc" rule="okapi,k1:1.2,b:0.75" topic_type="title+desc"`            | 0.2702 | 0.3274 | 0.4618 | 0.4517 |
| :nine: `--opts out_file_name="robust.bm25.title+desc.prf.sd" rule="method:dirichlet,mu:1000" topic_type="title+desc" use_prf="1" sd="1"`  | 0.2971 | 0.3562 | 0.4550 | 0.4448 |
| :keycap_ten: `--opts out_file_name="robust.dir1000.desc" rule="method:dirichlet,mu:1000" topic_type="desc"`  | 0.2023 | 0.2581 | 0.3703 | 0.3635 |


**How do we fare compared to Indri results reported in papers?** Here, we are considering the `Robust04` numbers reported by researchers working at the institute developing/maintaining Indri:
- [Query Reformulation Using Anchor Text](http://www.wsdm-conference.org/2010/proceedings/docs/p41.pdf) contains a language modeling experiment on `Robust04` that reports a `P@10` of 0.395 for an unstemmed index (and 246 topics instead of 249). Similar setup to run :one:.
- [Learning to Reweight Terms with Distributed Representations](https://www.cs.cmu.edu/~callan/Papers/sigir15-gzheng.pdf) offers several baselines with a Krovetz stemmed `Robust04` index with stopwords removed. The `BOW` model (language modeling with Dirichlet smoothing, similar to :one:) achieves a MAP of 0.2512, the `SD` model (language modeling with sequential dependency, similar to :two:) achieves a MAP of 0.2643. For BM25 (similar to :six:) the authors report a MAP of 0.2460.
- [Deeper Text Understanding for IR with Contextual Neural Language Modeling](https://arxiv.org/pdf/1905.09217.pdf) contains not a lot of details but reports a NDCG@20 of 0.417 for title queries (language modeling, similar to :one:) and 0.409 for description queries (language modeling, similar to :keycap_ten:). It is not entirely clear how the description topics were processed. Slightly higher values are reported for the `SD` model: 0.427 for title (similar to run :two:) as well as description queries.
- [Effective Query Formulation with Multiple Information Sources](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.366.7813&rep=rep1&type=pdf) reports an NDCG@20 of 0.4178 (title queries, similar to :two:) and 0.4085 (description queries) for the sequential dependence model.

Conclusion: the sequential dependency model outperforms the standard language modeling approach, though the absolute differences we observe are smaller. BM25 peforms worse than expected, this is likely a hyperparameter issue (we did not tune, used default values). The biggest difference can be found in the results involving TREC topic descriptions, a preprocessing issue (specific stopword phrases for description topics).

### `gov2`

The results below are computed based on the 150 topics available for `gov2`.

|       | MAP    | P@30    | P@10 | NDCG@20    |
|----------------------------------------------------------------------------------------------------------------------|--------|--------|--------|--------|
| :one: `--opts out_file_name="gov2.dir1000.title" rule="method:dirichlet,mu:1000" topic_type="title"`         | 0.2499 | ??? | 0.4253 | 0.4201 | 
| :two: `--opts out_file_name="gov2.dir1000.title.sd" rule="method:dirichlet,mu:1000" topic_type="title" sd="1"`         | 0.2547 | ??? | 0.4329 | 0.4232 |
| :three: `--opts out_file_name="gov2.dir1000.title.prf" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="1"`         | 0.2812 | ??? | 0.4386 | 0.4276 |
| :four: `--opts out_file_name="gov2.dir1000.title.prf.sd" rule="method:dirichlet,mu:1000" topic_type="title" use_prf="1" sd="1"`  | 0.2855 | ??? | 0.4474 | 0.4298 |
| :five: `--opts out_file_name="gov2.jm0.5.title" rule="method:linear,collectionLambda:0.5" topic_type="title"` | 0.2242 | ??? | 0.3819 | 0.3689 |
| :six: `--opts out_file_name="gov2.bm25.title" rule="okapi,k1:1.2,b:0.75" topic_type="title"`            | 0.2338 | ??? | 0.4181 | 0.4041 |
| :seven: `--opts out_file_name="gov2.bm25.title.prf" rule="okapi,k1:1.2,b:0.75" topic_type="title" use_prf="1"`            | 0.2563 | ??? | 0.4012 | 0.3995 |
| :eight: `--opts out_file_name="gov2.bm25.title+desc" rule="okapi,k1:1.2,b:0.75" topic_type="title+desc"`            | 0.2702 | ??? | 0.4618 | 0.4517 |
| :nine: `--opts out_file_name="gov2.bm25.title+desc.prf.sd" rule="method:dirichlet,mu:1000" topic_type="title+desc" use_prf="1" sd="1"`  | 0.2971 | ??? | 0.4550 | 0.4448 |
| :keycap_ten: `--opts out_file_name="gov2.dir1000.desc" rule="method:dirichlet,mu:1000" topic_type="desc"`  | 0.2023 | ??? | 0.3703 | 0.3635 |

## Implementation

The following is a quick breakdown of what happens in each of the scripts in this repo.

### Dockerfile

The `Dockerfile` installs dependencies (`python3`, etc.), copies scripts to the root dir, and sets the working dir to `/work`. It also installs Indri.

### index

The `robust04` corpus is difficult to handle for Indri: the original version is `.z` compressed, a compression Indri cannot handle. And thus, [indexRobust04.sh](indexRobust04.sh) first uncompresses the collection, filters out undesired folders (such as `cr`), downloads Lemur's stopword list, creates a parameter file for indexing and finally calls Indri's `IndriBuildIndex`.

In contrast, the formatting of `gov2` is well suited for Indri, apart from creating a parameter file and calling Indri's `IndriBuildIndex, not much happens.

### search

The `robust04` and `gov2` topics are in "classic" TREC format, a format Indri cannot handle. Thus, first the TREC topic file has to be converted into a format Indri can parse (done in [topicFormatting.pl](topicFormatting.pl)). Note: different retrieval methods require differently formatted Indri topic files. A parameter file is created and finally `IndriRunQuery` is executed.

## Reviews

+ Documentation not yet reviewed