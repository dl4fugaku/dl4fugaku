These are notes in addition to the README.md of Fujitsu's [github repo](https://github.com/fujitsu/pytorch/tree/fujitsu_v1.7.0_for_a64fx/scripts/fujitsu). 
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
