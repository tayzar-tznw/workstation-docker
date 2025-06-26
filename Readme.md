Contains
- agent-starter-pack
- terraform
- python, terraform, jupyter notebook plugin

Create WS config
```shell
gcloud workstations configs create workshop-config-optimal \
--cluster=workshop-cluster \
--region=asia-northeast1 \
--container-custom-image="docker.io/tznw/workstation:optimal" \
--machine-type="e2-standard-8" \
--pool-size=1 \
--idle-timeout=21600 \
--pd-disk-size=100 \
--pd-disk-type="pd-ssd"
```

