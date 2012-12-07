#!/bin/bash
rake db:drop
rake db:migrate
rake db:seed
rake db:test:prepare
rails s