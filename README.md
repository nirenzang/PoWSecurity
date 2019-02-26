# Analyzing PoW Protocols's Security
This is the evaluation code used in the [40th IEEE Symposium on Security &amp; Privacy (S&P'19)](https://www.ieee-security.org/TC/SP2019/) paper ["Lay Down the Common Metrics: Evaluating Proof-of-Work Consensus Protocols' Security"](https://www.esat.kuleuven.be/cosic/publications/article-3005.pdf) by [Ren Zhang](https://scholar.google.be/citations?user=JB1uRvQAAAAJ&hl=en) and [Bart Preneel](https://scholar.google.be/citations?user=omio-RsAAAAJ&hl=en). Developed by Ren Zhang.

The code computes the optimal strategies and the maximum utilities of an attacker within different PoW protocols and attacker goals (security metrics), under different mining power distributions and network propagation parameters. Please check the paper for the complete definitions of the settings. Note that some simple conversions might be required to compute the security metrics from the MDP outputs. The following metric-protocol pairs are included in this repository:

* Metric: chain quality
  * [Nakamoto consensus](https://bitcoin.org/en/bitcoin-paper)
  * [Publish or perish](https://www.esat.kuleuven.be/cosic/publications/article-2746.pdf)
  * [Uniform tie-breaking](https://www.cs.cornell.edu/~ie53/publications/btcProcFC.pdf)
  * [Smallest-hash tie-breaking](https://scalingbitcoin.org/papers/DECOR-HOP.pdf)
  * Unpredictable deterministic tie-breaking [1](https://scalingbitcoin.org/papers/DECOR-LAMI.pdf), [2](http://www.bubifans.com/ueditor/php/upload/file/20181015/1539596900526563.pdf)
* Attack-resistance metrics: incentive compatibility, subversion gain and censorship susceptability
  * Nakamoto consensus
  * [Fruitchains](https://eprint.iacr.org/2016/916.pdf)
  * Reward-splitting protocol [1](https://scalingbitcoin.org/papers/DECOR-HOP.pdf), [2](https://scalingbitcoin.org/papers/DECOR-LAMI.pdf)
  * [Subchains](https://www.bitcoinunlimited.info/resources/subchains.pdf)

Note that although reward-splitting protocol is a simplified version of DECOR+, their attack resistance results are not the same.

The MDP state encoding and transition are quite complicated: many information regarding the structure of the blockchain needs to be encoded in the state to help the attacker make decisions. Therefore if you wish to fully understand and modify this source code rather than using it as a blackbox to execute and compare the results, the developer strongly recommend you to read the paper ["the Optimal Selfish Mining Strategies"](http://www.cs.huji.ac.il/~yoni_sompo/pubs/15/SelfishMining.pdf) and understand [my implementation](https://github.com/nirenzang/Optimal-Selfish-Mining-Strategies-in-Bitcoin) of their algorithm before modifying this code. 

## Quick Start
If you only need the results:
1. Make sure you have matlab.
2. Download the [MDP toolbox for matlab](https://nl.mathworks.com/matlabcentral/fileexchange/25786-markov-decision-processes--mdp--toolbox), decompress it, put it in a directory such as '/users/yourname/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox', copy the path.
3. Download the code, open Matlab, change the working dir to the dir of the code.
4. Open `Init.m`, paste your MDP toolbox path in the first line 
```
addpath('/users/yourname/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');
```
5. Modify the parameters in `Init.m`. See their definitions in the paper.
6. Run `Init.m`.

## Implementation
* `Init.m`
The portal of the program. The parameters are specified here.
* `InitStates.m`
Initiate the state transition matrix, reward distribution matrix, etc.
* `st2stnum.m`
In an MDP, a state needs to be encoded as a number. This function converts a state tuple into the relevant number. 
* `stnum2st.m` 
This function does the reverse conversion.
* `InitStnum.m`
Compute the total number of states.
* `SolveMDP.m`
Compute the optimal mining strategies. The structure of the code follows the paper.
* `Checkstnum2st.m`
A test file, check whether `st2stnum.m` and `stnum2st.m` make a bijection.

## Citation
Zhang R., Preneel B. (2019) Lay Down the Common Metrics: Evaluating Proof-of-Work Consensus Protocols' Security. To appear in the 40th IEEE Symposium on Security & Privacy (S&P'19), May 2019.
```
@inproceedings{Zhang2019CommonMetrics,
 author = {Ren Zhang and Bart Preneel},
 title = {Lay Down the Common Metrics: Evaluating Proof-of-Work Consensus Protocols' Security},
 booktitle = {Proceedings of the 40th IEEE Symposium on Security and Privacy},
 series = {S\&P '19},
 year = {2019},
 publisher = {IEEE}
} 
```
Chadès, I., Chapron, G., Cros, M. J., Garcia, F., & Sabbadin, R. (2014). MDPtoolbox: a multi‐platform toolbox to solve stochastic dynamic programming problems. Ecography, 37(9), 916-920.
```
@article{chades2014mdptoolbox,
  title={MDPtoolbox: a multi-platform toolbox to solve stochastic dynamic programming problems},
  author={Chad{\`e}s, Iadine and Chapron, Guillaume and Cros, Marie-Jos{\'e}e and Garcia, Fr{\'e}d{\'e}rick and Sabbadin, R{\'e}gis},
  journal={Ecography},
  volume={37},
  number={9},
  pages={916--920},
  year={2014},
  publisher={Wiley Online Library}
}
```

## License
This code is licensed under GNU GPLv3.
