#!/bin/bash
# Post-renewal hook: reload nginx inside the TaxonWorks container
docker exec app-tw-1 nginx -s reload
