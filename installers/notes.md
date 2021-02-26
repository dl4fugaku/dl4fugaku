# Installing Pytorch

These are notes in addition to the README.md of Fujitsu's [github repo](https://github.com/fujitsu/pytorch/tree/fujitsu_v1.7.0_for_a64fx/scripts/fujitsu). 
You should primarily follow the README.md, but the idea is to just copy paste these commands and make everything work like magic (which reminds me that I should put these in a bash script).
My insall process looks something like this:

```shell
git clone git@github.com:fujitsu/pytorch.git pytorch-fujitsu
cd pytorch-fujitsu
git checkout fujitsu_v1.7.0_for_a64fx
cd scripts/fujitsu/
sed -i -e 's!PREFIX=.*!PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null ; pwd)"!' env.src
sed -i -e 's!TCSDS_PATH=.*!TCSDS_PATH=/opt/FJSVxtclanga/tcsds-1.2.29!' env.src
sed -i -e 's/rscgrp=ai-default/rscgrp=eap-small/' submit_*.sh opennmt_build_pack/submit_*.sh
./checkout.sh
pjsub submit_build.sh
# and then follow readme
```

## Notes on the `sed`s

- First `sed` substitutes the magic command which evaluates to the current directory of `env.src`.
- Second `sed` sets the path to the compiler. This needs to be the path **on the compute node** (not the login node).
- Third `sed` sets the resource group.  Run `pjstat --rsc` to see the resource groups.

# If everything worked

If the jobs complete successfully, you probably want a single file which will activate the venv created by the install scripts.  Put this file in the `<pytorch-fujitsu-repo>/scripts/fujitsu` dir (where the install scripts are):
```shell
cat data/pytorch-fujitsu/scripts/fujitsu/activate.sh 
PREFIX="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null ; pwd )"
source ${PREFIX}/env.src
source ${PREFIX}/fccbuild_v170/bin/activate
```