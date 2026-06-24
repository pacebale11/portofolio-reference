# Changelog

## 3.5.0

- support ignore changes on resource labels for node pool

## 3.4.0

- support ignore changes on kubelet config for node pool

## 3.3.0

- support allow disabling GKE usage tracker through BQ
- support allow disabling Pub/Sub upgrade notifier

## 3.2.2

- default node pool will use first declared nodepool's service account instead of compute default service account, only when there is no node pool defined, it will fall back to using default compute service account

## 3.2.1

- Add datasource block for big query and pubsub topic for validation before creating GKE

## 3.2.0

- Require version 5.x onwards of `google` and `google-beta` providers.
- Allow using terraform binary version 1.x onwards.
- Allow configuring `deletion_protection` setting (enabled by default).

## 3.1.0

- Add `sysctl_config` variable to allow configuring sysctl parameters on node pools

## 3.0.0

Breaking changes:
- Removed `enable_gce_persistent_disk_csi_driver` variable.
- Set the `gce_persistent_disk_csi_driver_config` to be enabled by default since it is required to use persistent disk as of GKE 1.25.

## 2.9.0

- Allow enabling [managed service for Prometheus](https://cloud.google.com/stackdriver/docs/managed-prometheus).

## 2.8.0

- Move configuration for cluster logging from logging_service to logging_config block to fix issue shown in this image during cluster creation

![image](https://gitlab.com/host-id/host-host/infra/terraform-modules/uploads/4aa18717ae35caf39ecb198ffc36636e/image.png)

- Also move configuration for cluster monitoring from monitoring_service to monitoring_config block

## 2.7.0

- Allow to configure max pod per node in GKE

## 2.6.0

- Allow [disabling default SNAT](https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#confirm_whether_default_snat_is_disabled) from Terraform, and disable it by default

## 2.5.0

- Add config `logging_variant` on node pool level to optionally configure [high throughput logging agent](https://cloud.google.com/stackdriver/docs/solutions/gke/managing-logs#collecting_logs)

## 2.4.0

- Add config `monitoring_config` to enable GKE Control Plane Metrics

## 2.3.0

- Add autoscaling features for upcoming 1.24 update in Govtech's cluster
  - autoscaling_total_min_node_count
  - autoscaling_total_max_node_count
  - autoscaling_location_policy
- Update module to use provider version 4.48.0 that fix some issue with `location_policy` variable

## 2.2.0

- Remove `module_variable_optional_attrs` experiment as it has been concluded in terraform `1.3.0` onwards.
- Change minimum requirement to terraform `1.3.0`.

## 2.1.0

- Added `enable_cost_allocation` variable, defaults to `true`, to control whether Cost Allocation is enabled or not. See [this GKE documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/cost-allocations) for more details.

## 2.0.0

- Added two new variables related to Kubernetes NetworkPolicy:
  - `enable_network_policy_addon`, defaults to `true`, to control whether NetworkPolicy add-on is enabled or disabled. See [this GKE documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy#using_network_policy_enforcement) for more details.
  - `enforce_network_policy`, defaults to `true`, to enforce (or stop enforcing) NetworkPolicy on the cluster level. See [this GKE documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy#using_network_policy_enforcement) for more details.

Breaking changes:

- By default, GKE cluster declared using this version will enforce NetworkPolicy.
- `network_policy_provider` variable will not automatically enforce NetworkPolicy on the cluster as before. `enable_network_policy_addon` and `enforce_network_policy` need to be used to control whether enforcement and add-on is enabled or disabled.

## 1.0.0

- Initial release since moving out the module from [the main Terraform repository](https://gitlab.com/host-id/host-host/infra/terraform).
- Loosen version constraints on `terraform.tf`.
  - This is to allow upgrades on [the main Terraform repository](https://gitlab.com/host-id/host-host/infra/terraform) without needing to adjust `terraform.tf` on this repository.
