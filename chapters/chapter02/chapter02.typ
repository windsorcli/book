#import "@preview/in-dexter:0.7.2": *
#import "/src/utils/page-break-helpers.typ": *
#import "/src/template.typ": subheading, troubleshooting-start, troubleshooting-end

= Local Development Workflows
#index("local development")

Local development for cloud-native applications presents unique challenges and opportunities. This chapter examines the philosophy behind running complete cloud environments locally, the infrastructure components required, and how Windsor implements this approach.

== The Philosophy of Local Cloud Development

Modern cloud-native applications are designed to run in distributed, containerized environments with complex networking, service discovery, and infrastructure dependencies. Traditional local development approaches—running individual services in isolation or mocking cloud dependencies—create a significant gap between development and production environments.

Local cloud development takes a different approach: running a complete, containerized cloud environment on your development machine. This means your laptop becomes a miniature data center, complete with container orchestration, DNS resolution, container registries, storage systems, load balancing, virtualization, and source control services.

=== Benefits of Local Development

Running cloud environments locally provides several fundamental advantages:

*Cost Efficiency*: Local development eliminates cloud resource costs during the development cycle. No compute charges, no data transfer fees, no accidental resource provisioning.

*Performance*: Local resources provide immediate feedback. Container builds, deployments, and service restarts happen in seconds rather than minutes. Network latency between services is negligible.

*Energy Efficiency*: A single development machine consumes significantly less energy than equivalent cloud resources, especially when considering the overhead of cloud infrastructure and cooling.

*Development Intimacy*: Direct access to logs, metrics, and debugging tools without network hops or authentication barriers. You can inspect, modify, and restart any component instantly.

*Offline Capability*: Once configured, local environments operate without internet connectivity, enabling development during travel or network outages.

=== Hardware Requirements and Recommendations
#index("hardware requirements")

Local cloud development requires substantial computational resources, as you're essentially running a data center on your laptop. Modern development machines should meet these minimum specifications:

*Minimum Requirements*:
- 16 GB RAM (32 GB strongly recommended)
- 8-core CPU (Apple M-series, Intel i7/i9, AMD Ryzen 7/9)
- 500 GB available SSD storage
- Non-virtualized environment (native macOS, Windows, or Linux)

*Recommended Configuration*:
- 32-64 GB RAM for complex multi-service applications
- 12+ core CPU (Apple M2 Pro/Max, Intel i9, AMD Ryzen 9)
- 1 TB+ NVMe SSD storage
- Dedicated development machine (not shared with other intensive workloads)

*Platform Considerations*:
- *Apple Silicon (M1/M2/M3)*: Excellent performance per watt, native container support
- *Windows with WSL2*: Good performance, requires WSL2 for container compatibility and Linux-based development tools
- *Linux*: Native container performance, minimal overhead

The investment in development hardware pays dividends in productivity. A well-equipped development machine eliminates the friction of slow builds, resource constraints, and network dependencies that plague underpowered setups.

== Local Infrastructure Components

Windsor creates a complete local cloud environment using Docker Compose orchestration. The environment includes Kubernetes clusters, DNS services, container registries, and cloud service emulation—all running as coordinated Docker containers on your development machine.

== Environment Management

Windsor manages development environments through shell hooks that inject configuration when entering project directories. The system automatically configures Docker contexts, Kubernetes credentials, and cloud CLI tools to target local infrastructure.

Each context maintains isolated credentials and tool configurations, preventing interference between projects.

== Local Virtualization Options

Windsor supports multiple virtualization approaches to accommodate different operating systems, performance requirements, and development preferences. The choice of virtualization backend affects both the capabilities available and the performance characteristics of the local environment.

=== Virtualization Backend Selection

The system automatically selects appropriate virtualization backends based on the operating system and available tools. On macOS and Windows, Docker Desktop is chosen by default for compatibility and ease of use. On Linux systems, native Docker is preferred for optimal performance. However, developers can override these defaults using command-line flags during initialization.

The `--colima` flag forces the use of Colima virtualization, which provides full VM-based isolation and supports advanced networking features. This option is particularly useful when developing applications that require specific network configurations or when testing multi-node scenarios.

Default virtualization selection follows this logic:
- macOS: Docker Desktop (default), Colima (with `--colima` flag)
- Windows: Docker Desktop (default, requires WSL2 backend)
- Linux: Native Docker (default), Colima (with `--colima` flag)

=== Docker Desktop Integration
#index("Docker Desktop")

Docker Desktop provides lightweight containerization suitable for most development workflows. This backend leverages Docker's built-in networking and volume management, making it ideal for applications that primarily use containers without requiring complex networking scenarios.

When using Docker Desktop, DNS resolution routes through localhost with port forwarding. Container registries operate on localhost ports, and the Kubernetes cluster runs as containers within Docker Desktop's VM. This configuration provides good performance for typical development tasks while maintaining compatibility across different host operating systems.

The Docker Desktop backend automatically configures Docker contexts and ensures that the Docker daemon is accessible through standard Unix sockets (macOS/Linux) or named pipes (Windows), depending on the host operating system. Environment variables are set to point development tools to the correct Docker endpoints.

#info-box(
  type: "warning",
  [
    *Configuring Docker Desktop Storage*
    #index("Docker Desktop configuration")

    Windsor's local environment requires substantial disk space for container images, Kubernetes cluster data, and application storage. You must increase Docker Desktop's default storage allocation:

    1. Open Docker Desktop and navigate to *Settings* → *Resources*
    2. Increase the *Disk image size* to at least *100 GB* (recommended: 150+ GB for complex applications)
    3. Adjust *Memory* to at least *8 GB* (recommended: 16+ GB)
    4. Set *CPUs* to at least *4 cores* (recommended: 6+ cores)
    5. Click *Apply & Restart* to save changes

    *Windows Additional Requirements:*
    - Ensure WSL2 backend is enabled in *Settings* → *General* → *Use the WSL 2 based engine*
    - Install WSL2 if not already present: `wsl --install` in PowerShell as Administrator
    - Verify WSL integration in *Settings* → *Resources* → *WSL Integration*

    The default Docker Desktop allocation may be insufficient for Windsor's local cloud environment. Insufficient storage will cause container pull failures and Kubernetes pod crashes during startup.
  ]
)

=== Colima Full Virtualization
#index("Colima")

Colima (Containers on Linux on macOS) is an open-source container runtime that provides full virtualization capabilities through Lima and native hypervisor frameworks. Unlike Docker Desktop's lightweight containerization approach, Colima creates a complete Linux VM that hosts all development infrastructure, enabling features not available in lightweight containerization.

Colima serves as a Docker Desktop alternative, particularly popular among developers who prefer open-source solutions or need more control over their container runtime environment. Windsor can be configured to use Colima during project initialization with `windsor init local --colima`. For more information about Colima, visit the official homepage at https://github.com/abiosoft/colima.

Full virtualization supports advanced networking with addressable IP ranges, Layer 2 load balancing, and device emulation. DNS resolution works with actual IP addresses rather than localhost routing, providing a more production-like environment.

Colima configuration includes CPU, memory, and disk allocation based on system resources. The system automatically calculates appropriate defaults but allows manual override through configuration files. VM networking is configured with bridge interfaces and custom DNS resolvers to support the full range of Windsor's networking features.

=== Performance and Resource Considerations

Both Docker Desktop and Colima provide high-performance container environments suitable for Windsor development. Your choice depends on feature requirements rather than performance limitations.

Docker Desktop offers a comprehensive GUI experience with enterprise features and broad compatibility. Colima provides a lightweight, command-line focused experience with advanced features like multi-architecture support and multiple container runtime options.

Colima enables additional capabilities that can be valuable for development workflows, including fine-grained resource control, multiple virtualization profiles, and direct access to advanced container runtime features.

Resource allocation for Colima defaults to half of available system resources for both CPU and memory, with a 60GB disk allocation. These defaults can be adjusted based on development requirements and system capabilities.

Performance optimization includes container registry caching, persistent volume management, and network optimization. All virtualization backends support Docker layer caching and persistent storage to minimize rebuild times and preserve development state across environment restarts.

== Local Cloud Environment Architecture

Windsor implements local cloud development through Docker Compose orchestration. The entire local environment runs as a coordinated set of Docker containers managed by a single `docker-compose.yaml` file located in `.windsor/docker-compose.yaml`. The diagram below shows the actual containers running in a Windsor local environment, including the Kubernetes cluster nodes, container registries, DNS services, and development tools.

#figure(
  image("/diagrams/generated/windsor-local-environment.png", width: 100%),
  caption: [Windsor's Local Environment Architecture]
) <fig-windsor-local-environment>

=== Kubernetes Cluster

The local Kubernetes cluster runs as Talos-based containers, providing production-like container orchestration. Applications deployed to this cluster operate using standard Kubernetes APIs, though scaling is constrained by local machine resources.

=== DNS and Service Discovery
#index("DNS configuration")

Windsor runs a CoreDNS container (`dns.test`) that provides local DNS resolution for the `.test` domain. This enables both service discovery and application access using domain names rather than IP addresses. Internal services can connect to each other using names like `registry.test` or `controlplane-1.test`, while developers can access their applications through URLs like `https://my-app.test` in their web browsers.

=== Container Registry Stack

Windsor deploys pull-through image caches that provide offline capability and faster image pulls. The `registry.test` serves as the primary local registry, while proxy caches for major public registries (GitHub, Google, Quay, Docker Hub) eliminate repeated downloads during development.

=== Development Services and Application Access

Windsor includes a Git live-reload service (`git.test`) that automatically triggers deployments when code changes are saved. Applications are accessible through real URLs like `https://my-app.test` via the ingress controller, eliminating port forwarding and providing production-like access patterns.

=== Docker Compose Coordination

The entire local environment operates as a single Docker Compose stack, with all containers coordinated through a generated `docker-compose.yaml` file. This approach provides several advantages:

- *Unified Lifecycle Management*: Start, stop, and restart the entire environment with standard Docker Compose commands
- *Network Coordination*: All containers share a common Docker network with predictable DNS resolution
- *Resource Management*: Docker Compose handles container dependencies, startup ordering, and resource allocation
- *Configuration Consistency*: Environment variables, port mappings, and volume mounts are centrally managed

When you run `windsor up`, the system generates the Docker Compose configuration and executes `docker compose up` to bring the entire environment online. This abstraction allows developers to work with familiar Docker tooling while Windsor handles the complexity of multi-service orchestration.

== Your First Look at Windsor in Action

To make these concepts concrete, let's walk through what happens when you first encounter a Windsor project. This high-level overview will prepare you for the hands-on experience you'll have in the upcoming lab.

#subheading[Project Initialization]

Start by creating a new directory for your project and navigating into it:

#smart-code("mkdir my-windsor-project
cd my-windsor-project", lang: "bash")

*Windows Users*: Use the same commands in PowerShell, WSL2, or Command Prompt. Windsor works identically across platforms once Docker Desktop is configured with WSL2 backend. Run PowerShell as Administrator for your first `windsor up local` to properly configure DNS resolution.

When you start a new Windsor project, the first step is initialization:

#smart-code("windsor init local", lang: "bash")

You can also specify virtualization preferences during initialization:

#smart-code("windsor init local --colima    # Force Colima virtualization
windsor init local             # Use platform defaults", lang: "bash")

During initialization, you'll see Windsor downloading and loading components:

```
✔ 📥 Loading component cluster/talos - Done
✔ 📥 Loading component gitops/flux - Done
Initialization successful
```

This process downloads blueprint components from the Windsor core repository and sets up the local context structure. Windsor creates several key directories and files in your project directory:

- `contexts/local/` directory containing all context-specific configuration
- `blueprint.yaml` file defining your complete infrastructure stack
- `terraform/` subdirectories within the context containing Terraform variable files for cluster and GitOps configuration
- Hidden `.terraform/` directory with Terraform state and modules

The initialization creates a comprehensive blueprint that includes:
- Talos Kubernetes cluster configuration
- Flux GitOps workflow setup
- Container registry mirrors and caching
- DNS and networking configuration
- Storage, ingress, and observability components
- Policy and security configurations

At this point, you have a complete project structure, but nothing is running yet. The initialization step downloads the necessary components and generates configuration files that define your complete local cloud environment.

#subheading[Understanding the Directory Structure]

Windsor creates a specific directory structure that organizes your local development environment. After running `windsor init local`, you'll find:

```
my-windsor-project/            # Your project root
├── contexts/                  # All context configurations
│   └── local/                 # Local context-specific configuration
│       ├── blueprint.yaml     # Complete infrastructure definition
│       ├── terraform/         # Terraform configuration
│       │   ├── cluster/
│       │   │   └── talos.tfvars    # Cluster configuration variables
│       │   └── gitops/
│       │       └── flux.tfvars     # GitOps configuration variables
│       └── .terraform/        # Terraform state and modules
│           ├── cluster/
│           └── gitops/
└── .windsor/                  # Windsor runtime files (created during windsor up)
    ├── docker-compose.yaml    # Generated Docker Compose configuration
    ├── Corefile               # DNS configuration
    ├── context                # Current context identifier
    └── .docker-cache/         # Docker layer cache
```

The separation between context configuration (`contexts/local/`) and runtime files (`.windsor/`) allows Windsor to manage multiple contexts while maintaining a clean separation of concerns. The context directory contains declarative configuration, while the Windsor directory contains generated runtime artifacts that are created when you run `windsor up`.

#subheading[Exploring the Generated Structure]

After initialization, your project contains several key files and directories. Let's examine the most important components:

#subheading[The Blueprint Definition]

The most important file is `contexts/local/blueprint.yaml`, which serves as the master configuration for your entire environment:

```yaml
kind: Blueprint
apiVersion: blueprints.windsorcli.dev/v1alpha1
metadata:
  name: local
  description: This blueprint outlines resources in the local context
repository:
  url: http://git.test/git/project
  ref:
    branch: main
sources:
- name: core
  url: oci://ghcr.io/windsorcli/core:v0.4.0
terraform:
- source: core
  path: cluster/talos
- source: core
  path: gitops/flux
kustomize:
- name: telemetry-base
  path: telemetry/base
  source: core
  components:
  - prometheus
  - prometheus/flux
- name: ingress
  path: ingress
  source: core
  dependsOn:
  - pki-resources
  components:
  - nginx
  - nginx/nodeport
  ...
```

The blueprint includes detailed Terraform configuration for both the Kubernetes cluster and GitOps workflows. The cluster configuration specifies:

*Repository*: The URL of the Git repository of the current project. In a local environment, this points to the local Git server running on your machine.

*Sources*: References to external blueprint repositories (like the Windsor core repository) that provide reusable infrastructure components.

*Terraform*: Infrastructure-as-code definitions that create the foundational resources like the Kubernetes cluster and GitOps workflows.

*Kustomize*: Kubernetes application deployments that install and configure services on top of the infrastructure.

#subheading[Terraform Configuration Files]

The `contexts/local/terraform/` directory contains `.tfvars` files that customize infrastructure modules:

- `cluster/talos.tfvars`: Kubernetes cluster configuration with node IP addresses and networking settings
- `gitops/flux.tfvars`: GitOps workflow configuration with Git credentials and webhook settings

This separation follows a clear architectural pattern: the blueprint defines *what* infrastructure components should be deployed, while the `.tfvars` files specify *how* those components should be configured for the specific environment. This abstraction separates declarative intent from environment-specific implementation details, enabling consistent infrastructure patterns across contexts.

#subheading[Understanding the Components]

The blueprint defines two main types of components:

*Terraform Components*: Create the foundational infrastructure including the Kubernetes cluster and GitOps workflows. These run first to establish the platform.

*Kustomize Components*: Deploy applications and services on top of the infrastructure. These include system services like ingress controllers, DNS, and monitoring tools.

Windsor handles the dependency ordering automatically, ensuring infrastructure is ready before applications are deployed.

#subheading[Runtime State Directories]

After running `windsor up`, several additional directories are created to store runtime state:

- `.kube/` - Kubernetes cluster credentials and configuration
- `.talos/` - Talos cluster certificates and machine configuration
- `.terraform/` - Terraform state and downloaded modules
- `.tfstate/` - Terraform state backups and lock files

These directories are automatically managed by Windsor and contain sensitive information, so they should not be committed to version control.

#subheading[Validating Your Environment]

Before starting your local environment, you should verify that all required tools are properly installed and configured. Run:

#smart-code("windsor check", lang: "bash")

This command validates that all tools required by your project are installed and meet minimum version requirements. If everything is properly configured, you'll see:

#smart-code("All tools are up to date.")

If there are missing tools or version issues, Windsor will provide specific guidance on what needs to be installed or updated.

#subheading[Environment Variable Injection]

You can see how environment management works by running:

```bash
windsor env
```

This command outputs all the environment variables that Windsor would inject for your current context:

```bash
export DOCKER_HOST="unix:///Users/username/.docker/run/docker.sock"
export K8S_AUTH_KUBECONFIG="/path/to/project/contexts/local/.kube/config"
export KUBECONFIG="/path/to/project/contexts/local/.kube/config"
export KUBE_CONFIG_PATH="/path/to/project/contexts/local/.kube/config"
export REGISTRY_URL="registry.test:5000"
export WINDSOR_CONTEXT="local"
export WINDSOR_CONTEXT_ID="weo5u9zf"
unset WINDSOR_MANAGED_ALIAS
export WINDSOR_MANAGED_ENV="CRITERION_PASSWORD,WINDSOR_CONTEXT,..."
export WINDSOR_PROJECT_ROOT="/path/to/project"
export WINDSOR_SESSION_TOKEN="iVDTw1h"
```

*Windows Output*: On Windows, the output uses Windows-style paths and environment variable syntax:

```cmd
set DOCKER_HOST=npipe:////./pipe/docker_engine
set K8S_AUTH_KUBECONFIG=C:\path\to\project\contexts\local\.kube\config
set KUBECONFIG=C:\path\to\project\contexts\local\.kube\config
set REGISTRY_URL=registry.test:5000
set WINDSOR_CONTEXT=local
```

Windsor injects a comprehensive set of environment variables that configure all development tools to work with the local environment:

#figure(
  table(
    columns: 2,
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { gray.lighten(80%) } else { none },
    align: (left, left),
    table.header(
      [*Variable*], [*Description*]
    ),
    [`WINDSOR_CONTEXT`], [Identifies the current context ("local")],
    [`WINDSOR_CONTEXT_ID`], [Unique identifier for this context instance],
    [`WINDSOR_PROJECT_ROOT`], [Absolute path to the project directory],
    [`WINDSOR_SESSION_TOKEN`], [Session-specific cache and scope token used internally by Windsor],
    [`WINDSOR_MANAGED_ENV`], [List of all variables Windsor manages],
    [`DOCKER_HOST`], [Points Docker commands to the correct daemon],
    [`KUBECONFIG`], [Configures kubectl to access the local cluster],
    [`K8S_AUTH_KUBECONFIG`], [Additional Kubernetes authentication path],
    [`KUBE_CONFIG_PATH`], [Alternative kubectl configuration variable],
    [`REGISTRY_URL`], [Local container registry endpoint for builds]
  ),
  caption: [Default environment variables injected by Windsor Shell Hook]
)

This is exactly what gets automatically injected when you have Windsor's shell hook installed - the hook runs `windsor env` behind the scenes and applies these variables to your shell environment when you enter the project directory.

#section-with-content(
  [=== Starting Your Local Environment],
  [
    Once your tools are validated and you understand the environment configuration, you can start your local cloud environment:

    #smart-code("windsor up", lang: "bash")

    *Windows Users*: Run PowerShell as Administrator for your first `windsor up local` to properly configure DNS resolution for the `.test` domain.
  ]
)

The startup process follows a specific sequence that you'll see in the output:

```
✔ 📥 Loading component cluster/talos - Done
✔ 📥 Loading component gitops/flux - Done
✔ 📦 Running docker compose up - Done
Password: [system password prompt for DNS configuration]
✔ 🔐 Configuring DNS resolver at /etc/resolver/test - Done
✔ 🔐 Flushing DNS cache - Done
✔ 🔐 Restarting mDNSResponder - Done
✔ 🌎 Planning Terraform changes in cluster/talos - Done
✔ 🌎 Applying Terraform changes in cluster/talos - Done
✔ 🌎 Initializing Terraform in gitops/flux - Done
✔ 🌎 Planning Terraform changes in gitops/flux - Done
✔ 🌎 Applying Terraform changes in gitops/flux - Done
Windsor environment set up successfully.
```

This process involves several critical steps:

1. *Docker Compose Startup*: Windsor generates a `docker-compose.yaml` file in `.windsor/docker-compose.yaml` and starts all supporting containers (registries, DNS, Git service)

2. *DNS Configuration*: Windsor configures system DNS resolution for the `.test` domain, requiring administrator privileges. On macOS, this creates resolver files in `/etc/resolver/`. On Windows, this configures the Windows DNS resolver. This allows you to access services using domain names like `https://my-app.test`

3. *Terraform Initialization*: Windsor initializes Terraform modules for both cluster creation and GitOps configuration

4. *Cluster Bootstrap*: Terraform applies the Talos cluster configuration, which can take several minutes as it:
   - Creates Talos machine secrets and certificates
   - Applies machine configuration to control plane and worker nodes
   - Bootstraps the Kubernetes cluster
   - Waits for all nodes to become ready

The initial startup can take 5-10 minutes as Windsor downloads container images, initializes the Kubernetes cluster, and runs the complete Terraform bootstrap process. Subsequent startups are much faster as images are cached locally.

#subheading[Exploring the Running Environment]

Once `windsor up` completes, you can explore the running environment using standard Docker and Kubernetes commands. To see only Windsor-managed containers, use:

#smart-code("docker ps --filter \"label=managed_by=windsor\"", lang: "bash")

This shows all containers that Windsor created and manages, including the Kubernetes nodes, registries, DNS service, and Git live-reload service. Each container includes Windsor-specific labels that identify its role and context.

You can also inspect individual containers to see their configuration:

#smart-code("docker inspect registry-1.docker.test", lang: "bash")

This reveals the container's network configuration, volume mounts, environment variables, and labels that Windsor uses for orchestration.

You can also view the logs of any Windsor-managed container directly. For example, to see the Talos control plane logs:

```bash
docker logs controlplane-1.test
```

This provides direct access to the Kubernetes control plane logs, which is invaluable for debugging and understanding cluster behavior during local development.

#subheading[Understanding the Generated Docker Compose Configuration]

Windsor generates a comprehensive Docker Compose configuration in `.windsor/docker-compose.yaml`. This file defines the complete local cloud environment:

```yaml
services:
  controlplane-1:
    container_name: controlplane-1.test
    image: ghcr.io/siderolabs/talos:v1.9.5
    networks:
      windsor-local:
        ipv4_address: 10.5.0.2
    privileged: true
    environment:
      PLATFORM: container
      TALOSSKU: 2CPU-2048RAM

  worker-1:
    container_name: worker-1.test
    image: ghcr.io/siderolabs/talos:v1.9.5
    networks:
      windsor-local:
        ipv4_address: 10.5.0.3
    privileged: true

  registry:
    container_name: registry.test
    image: registry:2.8.3
    networks:
      windsor-local:
        ipv4_address: 10.5.0.10
```

Key aspects of the Docker Compose configuration:

- *Fixed IP Addresses*: Each container receives a predictable IP address in the `10.5.0.0/24` network
- *Privileged Containers*: Talos nodes run with privileged access to manage the Kubernetes cluster
- *Registry Mirrors*: Multiple registry containers provide caching and offline capability
- *DNS Integration*: All containers use the `.test` domain for service discovery
- *Network Isolation*: The `windsor-local` network provides isolation from other Docker workloads

This configuration ensures that your local environment behaves consistently and provides production-like networking patterns.

=== Installing the Default Blueprint

After your cluster is running, install the default application and infrastructure components with:

#smart-code("windsor install --wait", lang: "bash")

This command applies the default Windsor blueprint to your local environment, deploying core infrastructure and any sample applications defined in your project. The `--wait` flag ensures the command waits for all resources to become ready before returning. This step completes the initial setup of your local cloud environment.

=== Exploring the Running Cluster

Once `windsor install --wait` completes, you can explore the comprehensive infrastructure that Windsor has deployed. Start by examining the cluster nodes:

#command-with-output(
  "kubectl get nodes -o wide",
  "NAME             STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP
controlplane-1   Ready    control-plane   6h    v1.33.2   10.5.0.2      <none>
worker-1         Ready    <none>          6h    v1.33.2   10.5.0.11     <none>"
)

This shows your local Talos-based Kubernetes cluster with both control plane and worker nodes:

The cluster includes a full production-like infrastructure stack organized into system namespaces. View all namespaces to see the Windsor-managed infrastructure:

#command-with-output(
  "kubectl get namespaces",
  "NAME                            STATUS   AGE
system-csi                      Active   6h     # Storage management
system-dns                      Active   6h     # DNS and service discovery
system-gitops                   Active   6h     # Flux GitOps controllers
system-ingress                  Active   6h     # NGINX ingress controller
system-observability            Active   6h     # Grafana dashboards
system-pki                      Active   6h     # Certificate management
system-pki-trust                Active   6h     # Trust bundles
system-policy                   Active   6h     # Policy enforcement
system-telemetry                Active   6h     # Prometheus monitoring"
)

Look for the `system-*` namespaces that Windsor creates:

=== Accessing Deployed Applications

Windsor automatically configures ingress routes for accessing applications through `.test` domains. You can see configured ingress routes:

#command-with-output(
  "kubectl get ingress -A",
  "NAMESPACE              NAME      CLASS   HOSTS          ADDRESS         PORTS
system-observability   grafana   nginx   grafana.test   10.106.16.158   80"
)

Applications are accessible directly through their configured domains. For example, Grafana is available at `http://grafana.test` (note that you may need to use port 8080: `http://grafana.test:8080` or `https://grafana.test:8443` depending on your local configuration).

=== Monitoring and Observability

The local environment includes a complete monitoring stack:

#smart-code("kubectl get pods -n system-telemetry", lang: "bash")

This shows the Prometheus monitoring stack with metrics collection, alerting, and visualization:
- Prometheus server for metrics collection
- Alertmanager for alert handling
- Node exporters for system metrics
- Kube-state-metrics for Kubernetes metrics
- Metrics server for resource monitoring

#smart-code("kubectl get pods -n system-observability", lang: "bash")

The observability stack includes Grafana with pre-configured dashboards for monitoring your local infrastructure and applications.

=== Storage and Infrastructure Components

Windsor deploys OpenEBS for local storage management:

#command-with-output(
  "kubectl get storageclass",
  "NAME               PROVISIONER        RECLAIMPOLICY   VOLUMEBINDINGMODE
local              openebs.io/local   Delete          WaitForFirstConsumer
single (default)   openebs.io/local   Delete          WaitForFirstConsumer"
)

This provides persistent storage for applications that need it, using your local machine's disk space.

The infrastructure also includes:

*Certificate Management*: cert-manager handles TLS certificate provisioning and rotation for secure communication between services.

*Policy Enforcement*: Kyverno provides policy-as-code enforcement, ensuring deployments meet security and operational standards.

*GitOps Workflows*: Flux controllers enable GitOps deployments, automatically syncing applications from Git repositories.

*DNS and Service Discovery*: CoreDNS and external-dns handle both internal cluster DNS and integration with external DNS providers.

*Load Balancing*: NGINX ingress controller with MetalLB provides production-like load balancing capabilities.

=== Understanding Resource Usage

You can monitor the resource consumption of your local environment:

#smart-code("kubectl top nodes
kubectl top pods -A")

This shows CPU and memory usage across the cluster, helping you understand the resource requirements of your local cloud environment.

The complete infrastructure stack provides a production-like environment for developing, testing, and validating cloud-native applications locally.

=== Environment Activation

Once your project is initialized, Windsor's environment management automatically activates when you're in the project directory. The shell hook system ensures that your environment is always correctly configured for your current context without manual intervention.

=== The Development Workflow Preview

With Windsor configured, your development workflow becomes remarkably straightforward:

1. Make changes to your application code
2. Build and test locally using the same tools you'd use in production
3. Deploy changes to your local environment to see them running
4. Switch contexts to deploy to staging or production when ready

Throughout this workflow, Windsor ensures that your tools are configured correctly, your credentials are managed securely, and your local environment closely mirrors your production infrastructure.

== Conclusion

This chapter guided you through setting up and validating a complete local cloud environment with Windsor. You learned how to initialize a project, check prerequisites, start the environment, and verify that all core infrastructure is running. With your local environment operational, you are ready to explore Windsor's blueprint system and advanced deployment workflows in the next chapter.

#troubleshooting-start()

== Troubleshooting

// Academic styling with subtle borders and typography
#block(
  stroke: (left: 2pt + rgb("#8b4513"), top: 1pt + rgb("#d2b48c")),
  inset: (left: 1.5em, right: 1.2em, top: 1.2em, bottom: 1.2em),
  radius: (top-left: 3pt),
  width: 100%,
  breakable: true,
)[

#index("troubleshooting")
Windsor's local environment involves complex interactions between Docker, networking, and Kubernetes. Use this diagnostic checklist to systematically identify and resolve common issues.

  === Diagnostic Checklist

  When encountering issues, work through these checks in order:

  *Step 1: Verify Shell Hook Installation*
  #index("shell hook troubleshooting")

  Check if Windsor environment variables are active:

  #smart-code("env | grep WINDSOR", lang: "bash")

  On Windows PowerShell:

  #smart-code("Get-ChildItem Env: | Where-Object Name -like '*WINDSOR*'", lang: "powershell")

  ✓ Expected: Multiple `WINDSOR_*` variables should be present
  ✗ If missing: Shell hook not installed - refer to Chapter 1 for shell hook installation instructions

  *Step 2: Verify Docker Status*
  #index("Docker troubleshooting")

  Check Docker daemon is running:

  #smart-code("docker version", lang: "bash")

  ✓ Expected: Client and Server versions displayed
  ✗ If failed: Start Docker Desktop or Docker daemon

  *Step 3: Check Windsor Container Status*
  #index("container troubleshooting")

  Verify all Windsor containers are running:

  #smart-code("docker ps --filter \"label=managed_by=windsor\"", lang: "bash")

  ✓ Expected: Containers for `controlplane-1.test`, `worker-1.test`, `registry.test`, `dns.test`, `git.test`
  ✗ If missing containers: Run `windsor up` to start environment

  *Step 4: Test DNS Resolution*
  #index("DNS troubleshooting")

  Verify `.test` domain resolution:

  #smart-code("nslookup registry.test", lang: "bash")

  ✓ Expected: Resolves to `127.0.0.1` (docker desktop) or `10.5.X.X` (colima, docker native)
  ✗ If failed: DNS configuration issue - check resolver setup

  On macOS, verify resolver file exists:

  #smart-code("ls -la /etc/resolver/test", lang: "bash")

  On Windows, check DNS configuration:

  #smart-code("nslookup registry.test", lang: "powershell")

  *Step 5: Verify Kubernetes Configuration*
  #index("Kubernetes troubleshooting")

  Check that cluster configuration files exist:

  #smart-code("ls -la contexts/local/.kube/config
ls -la contexts/local/.talos/config", lang: "bash")

  ✓ Expected: Both configuration files should be present
  ✗ If missing: Cluster not properly bootstrapped - run `windsor up` again

  *Step 6: Verify Kubernetes Cluster*

  Check cluster node status:

  #smart-code("kubectl get nodes", lang: "bash")

  ✓ Expected: All nodes show `Ready` status
  ✗ If failed: Cluster bootstrap issue - check Terraform logs

  *Step 7: Check System Resources*
  #index("resource troubleshooting")

  Monitor resource usage:

  #smart-code("docker stats --no-stream", lang: "bash")

  ✓ Expected: Memory usage < 80%, no excessive CPU usage
  ✗ If high usage: Increase Docker resource allocation or close other applications

  === Common Recovery Actions

  *Environment Reset*

  If your environment becomes corrupted, restart cleanly:

  #smart-code("windsor down    # Stop and remove all containers
windsor up      # Restart the environment", lang: "bash")

  *Manual Container Cleanup*

  If Windsor commands fail, manually stop all containers:

  #smart-code("docker compose -f .windsor/docker-compose.yaml down", lang: "bash")

  This directly removes all Windsor containers without using Windsor's management layer.

  *Complete Cleanup*

  For persistent issues, perform complete cleanup:

  #smart-code("windsor down --clean", lang: "bash")

  This removes all containers, cached images, and Terraform state.

  *Failed Cluster Recovery*

  If Kubernetes cluster failed to initialize:

  #smart-code("windsor down --clean --skip-k8s", lang: "bash")

  The `--skip-k8s` flag prevents cleanup attempts when the cluster never started successfully.

  *Resource Allocation Issues*

  If containers fail to start due to insufficient resources:

  1. Increase Docker Desktop memory allocation to at least 8GB
  2. Increase CPU allocation to at least 4 cores
  3. Ensure at least 60GB of free disk space
  4. Close other resource-intensive applications

  *Windows-Specific Checks*
  #index("Windows troubleshooting")

  For Docker connectivity issues on Windows:

  #smart-code("# Verify Docker engine status
docker version

# Check WSL2 integration
wsl --list --verbose", lang: "powershell")

  If Docker fails to start:
  - Restart Docker Desktop using system tray icon
  - Verify WSL2 backend is enabled in Docker Desktop settings
  - Run `wsl --shutdown` and restart Docker Desktop if needed

  === Getting Detailed Diagnostic Output

  For more detailed troubleshooting information, use the `--verbose` flag with Windsor commands:

  #smart-code("windsor up --verbose      # Detailed startup logs
windsor down --verbose    # Detailed shutdown logs", lang: "bash")

  The verbose output provides full log details that can help identify specific failure points.

  === When to Seek Help

  If diagnostic steps don't resolve the issue:

  1. Check Docker Desktop status and restart if necessary
  2. Review container logs: `docker logs <container-name>`
  3. Run Windsor commands with `--verbose` flag for detailed output
  4. Verify system requirements are met
  5. Consult Windsor documentation for platform-specific guidance
  6. Post an issue on the Windsor GitHub repository with diagnostic output
]

#troubleshooting-end()

#figure(
  image("/chapters/chapter02/final_image.png", width: 60%),
)
