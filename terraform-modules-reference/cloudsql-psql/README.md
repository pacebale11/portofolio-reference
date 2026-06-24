# Cloud SQL for PostgreSQL

This Terraform module configures our Cloud SQL for PostgreSQL instances according to our standard:

* Location: GCP Jakarta region (`asia-southeast2`)
* [Version: using PostgreSQL 13 by default](https://cloud.google.com/sql/docs/postgres/db-versions)
* [Availability: Regional (highly available) on production projects, zonal (non-HA) elsewhere](https://cloud.google.com/sql/docs/postgres/high-availability)
* [Networking: using private VPC connections](https://cloud.google.com/sql/docs/postgres/private-ip); `vpc-production` for production projects and `vpc-staging` for staging projects
* [Logical replication and decoding enabled by default](https://cloud.google.com/sql/docs/postgres/replication/configure-logical-replication)

## Creating new Cloud SQL for PostgreSQL instances

This guide assumes you are familiar with `git`, including pushing your changes into a non-`master` branch, and submitting a merge request.

1. Create a file named `cloudsql.tf` under your project directory (under `environments/<env>/<project name>`) based on this template:
    ```terraform
    module "postgresql_<instance name>" {
      source = "git::https://gitlab.com/host-id/host-host/infra/terraform-modules.git//cloudsql-psql?ref=cloudsql-psql/1.0.0"

      project       = module.project.project_id
      environment   = module.project.environment
      disk_size     = 10 # disk size in GB, integer, min. 10 GB
      instance_name = "<instance name>"

      cpu    = 2    # number of cores, integer, either 1 or even number between 2 and 96
      memory = 4096 # amount of RAM for the instance, integer, in MB, 0.9 to 6.5 GB per CPU,
                    # in multiple of 256 MB, and at least 3.75 GB (3840 MB)

      labels = {
        tribe = "sds"
        squad = "sds"
      }

      # By default, the instance will only have private IP address on our private
      # network in the cloud. However, you can give the instance a public IP
      # address by uncommenting the line below:
      #
      # public_ip = true
      # authorized_networks = [
      #   {
      #     name  = "<description of this authorized network>"
      #     value = "<a single IPv4 address, or an IPv4 CIDR block>"
      #   },
      #   {
      #     name  = "<description of another authorized network>"
      #     value = "<a single IPv4 address, or an IPv4 CIDR block>"
      #   }
      # ]

      # by default the CloudSQL Postgre module will enable following flags
      #
      # "autovacuum" = "on"
      # "log_min_duration_statement" = "250"
      # "cloudsql.iam_authentication" = "off" # turn on by setting `enable_iam_authentication = true`
      # "cloudsql.logical_decoding" = "off"   # turn on by setting `logical_decoding = "on"`
      #
      # additional flags can be set using additional_database_flags variable
      # list of supported CloudSQL Postgre flags https://cloud.google.com/sql/docs/postgres/flags#list-flags-postgres
      additional_database_flags = {
        flag1         = "value1",
        "flag2.other" = "value2",
      }

      depends_on = [module.project]
    }

    # Optionally, create read replica instances by uncommenting the block below.
    #
    # module "postgresql_<instance name>_replica" {
    #   source = "git::https://gitlab.com/host-id/host-host/infra/terraform-modules.git//cloudsql-psql?ref=cloudsql-psql/1.0.0"
    #
    #   project              = module.project.project_id
    #   environment          = module.project.environment
    #   disk_size            = 10 # disk size in GB, integer, min. 10 GB
    #   instance_name        = "<instance name>-replica"
    #   master_instance_name = module.postgresql_<instance name>.name
    #
    #   cpu    = 2    # number of cores, integer, either 1 or even number between 2 and 96
    #   memory = 4096 # amount of RAM for the instance, integer, in MB, 0.9 to 6.5 GB per CPU,
    #                 # in multiple of 256 MB, and at least 3.75 GB (3840 MB)
    #
    #   labels = {
    #     tribe = "sds"
    #     squad = "sds"
    #   }
    #
    #   depends_on = [module.project]
    # }
    ```

1. Grant `roles/cloudsql.admin` role to your engineer's group by [following this guide](https://gitlab.com//host-id/host-host/infra/terraform/-/blob/master/modules/project-iam/README.md).
1. Commit, then push your changes to a new branch and create a new MR.
1. Follow the merge request workflow described in this page: https://docs.google.com/document/d/1fgMUkL0lNB7L1o4Uypui_Az6LApkpN3FCx6CbSlAhuk/edit?usp=drive_link to get your MR merged.
1. After the MR is merged, follow this documentation to provision SQL users and databases: https://docs.google.com/document/d/1urPkAFkF3MxyDFogop-zyA4vsLX3wGLLOmKOiSIK-n0/edit#heading=h.f6gnkfcrulr1.
