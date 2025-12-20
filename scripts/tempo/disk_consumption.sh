#!/bin/bash

kubectl exec -it -n tempo tempo-minio-main-pool-0 -- du -sh /export