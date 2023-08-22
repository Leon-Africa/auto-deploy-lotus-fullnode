````
export METAL_AUTH_TOKEN=
export METAL_ORGANIZATION_ID=
export TF_VAR_plan="c3.medium.x86"
export TF_VAR_metro="fr"
export TF_VAR_os="ubuntu_22_04"
````

````
metal env

METAL_AUTH_TOKEN=xxxxx
METAL_ORGANIZATION_ID=xx-xx-xx-xx-xxxx
METAL_PROJECT_ID=xxx-xx-xx-xx-xxx
METAL_CONFIG=/home/user/.config/equinix/metal.yaml
````

````
metal env --output terraform

TF_VAR_metal_organization_id=xxx-xxx-xxx-xxx-xxx
TF_VAR_metal_project_id=xxx-xxx-xxx-xxx-xxx
TF_VAR_metal_config=/home/user/.config/equinix/metal.yaml
TF_VAR_metal_auth_token=xxxxxxx

````
