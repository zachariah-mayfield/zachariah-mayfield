#!/bin/bash

unset no_proxy
unset NO_PROXY
unset no_proxy_override
unset NO_PROXY_OVERRIDE
unset http_proxy
unset HTTP_PROXY
unset https_proxy
unset HTTPS_PROXY

export no_proxy=".development.company-domain.com,.uat.company-domain.com,.production.company-domain.com,.blob.core.windows.net,.dfs.code.windows.net,localhost"
export NO_PROXY=".development.company-domain.com,.uat.company-domain.com,.production.company-domain.com,.blob.core.windows.net,.dfs.code.windows.net,localhost"
export no_proxy_override=""
export NO_PROXY_OVERRIDE=""
export http_proxy="http://zscaler-vse.Company-Domain.com:443"
export HTTP_PROXY="http://zscaler-vse.Company-Domain.com:443"
export https_proxy="http://zscaler-vse.Company-Domain.com:443"
export HTTPS_PROXY="http://zscaler-vse.Company-Domain.com:443"
