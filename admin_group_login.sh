#!/bin/bash

day_of_week=$(date +%u)

if groups $PAM_USER | grep -Pq "(\badmin\b|\bvagrant\b)"; then
        exit 0
else
        if (( $day_of_week > 5 )); then
                exit 1
        else
                exit 0
        fi
fi