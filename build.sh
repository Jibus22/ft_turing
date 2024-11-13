#!/bin/bash

opam switch list
status=$?
if [ $status -eq 0 ]; then
    echo "opam is initialized"
else
    opam init
fi

switch=$(opam switch show)
if [ $switch = "default" ]; then
    opam switch create .
    eval $(opam env)
else
    echo "not default"
fi
