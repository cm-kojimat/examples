resource "local_file" "secure" {
  filename             = ".envrc.secure"
  directory_permission = "0755"
  file_permission      = "0644"
  content              = <<EOF
export APPSYNC_API_KEY=${module.appsync.aws_appsync_api_key.this.key}
export APPSYNC_ENDPOINT_GRAPHQL=${module.appsync.aws_appsync_graphql_api.this.uris.GRAPHQL}
export APPSYNC_ENDPOINT_REALTIME=${module.appsync.aws_appsync_graphql_api.this.uris.REALTIME}

export REACT_APP_APPSYNC_API_KEY=${module.appsync.aws_appsync_api_key.this.key}
export REACT_APP_APPSYNC_ENDPOINT_GRAPHQL=${module.appsync.aws_appsync_graphql_api.this.uris.GRAPHQL}
export REACT_APP_APPSYNC_ENDPOINT_REALTIME=${module.appsync.aws_appsync_graphql_api.this.uris.REALTIME}
EOF
}

resource "local_file" "scripts_update_shadow_sh" {
  filename             = "scripts/update-shadow.sh"
  directory_permission = "0755"
  file_permission      = "0755"
  content              = <<EOF
#!/usr/bin/env bash

set -xueo pipefail

for iotname in ${join(" ", [for v in module.iot.aws_iot_thing.this : v.name])}; do
  aws iot-data update-thing-shadow \
    --thing-name $${iotname} \
    --shadow-name simShadow1 \
    --cli-binary-format raw-in-base64-out \
    --payload '{"state":{"desired":{"ColorRGB":[255,255,0]}},"clientToken":"21b21b21-bfd2-4279-8c65-e2f697ff4fab"}' \
    /dev/stdout
  done
EOF
}
