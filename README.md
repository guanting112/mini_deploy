Mini Deploy Tools ( beta )
=================================================

[![Gem Version](https://badge.fury.io/rb/mini_deploy.svg)](https://badge.fury.io/rb/mini_deploy)
[![Code Climate](https://codeclimate.com/github/guanting112/mini_deploy/badges/gpa.svg)](https://codeclimate.com/github/guanting112/mini_deploy)

Installation
--------

Via Rubygems

```shell
gem install mini_deploy
```

Usage
--------

![usage_output](http://i.imgur.com/s7Z5GEp.png)

```shell

# Create Sample Script
mdt install

# Start Receipts
mdt start receipts/sample.yml --host config/sample_hosts.yml

```

Sample hosts config
--------

```yaml
---

- node_id: NODE_ID_1
  host: 10.10.10.101
  ftp_username: sample
  ftp_password: "pass^00^"
  info:
    domain: example.com
    sample_file: sample.php
    error_log_file: error_log

- node_id: NODE_ID_2
  host: 10.10.10.102
  ftp_username: sample
  ftp_password: "pass^00^"
  info:
    domain: example-2.com
    sample_file: sample.php
    error_log_file: error_log

```

Sample receipt
--------

```yaml
---

title: Sample Deploy
date: 2017-01-02
author: Your Name
agent_name: SampleDeploy/1.0.0

deploy_nodes:
  - NODE_ID_1
  - NODE_ID_2

tasks:

  - process: upload_file
    upload_local_source: ./[info.sample_file]
    remote_path: ./[info.sample_file]
    upload_mode: binary
    tag: Test Upload File

  - process: send_http_request
    method: get
    url: http://[info.domain]/get
    tag: Test Http Get Request 
    params:
      test: "[info.domain]"

  - process: remove_file
    remote_file: ./[info.sample_file]
    tag: Remove file

  - process: send_http_request
    method: post
    params:
      author: Guanting Chen
      test: "[info.domain]"
    url: https://httpbin.org/post
    tag: Test Http Post Request 

  - process: check_file
    remote_file: ./[info.sample_file]
    tag: Check sample.php 

  - process: find_file_content
    remote_file: ./[info.sample_file]
    search_content: "[a-z]pple ="
    ignore_case: yes
    tag: Find sample.php content

```

LICENSE
--------

MIT LICENSE ( See LICENSE.txt ) 