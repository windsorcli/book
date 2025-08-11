#import "@preview/in-dexter:0.7.2": *

= Blueprint Fundamentals
#index("blueprints")
Blueprints define complete infrastructure systems through component composition. They specify how Terraform modules, Kubernetes resources, and application deployments work together to create functional environments. A blueprint describes the relationships between infrastructure layers and manages their deployment dependencies.

Blueprints organize complexity through systematic component selection. The Windsor Core library supplies vetted building blocks for typical infrastructure needs such as managed Kubernetes (`cluster/aws-eks`), bare metal clusters (`cluster/talos`), HTTP routing (`ingress/nginx`), monitoring dashboards (`observability/grafana`), and compliance enforcement (`policy/kyverno`). Your blueprint specifies which components to use and how they depend on each other.

Each blueprint can vary depending on your needs. A local development blueprint might include demo applications and simple networking. A production blueprint might include comprehensive monitoring, security policies, and cloud-native storage. An observability-focused blueprint might emphasize telemetry collection and dashboards. Blueprints are just YAML files that reference collections of infrastructure and application components.

For anyone building cloud-native applications on Kubernetes, blueprints enable high portability across environments. The same application stack can run locally for development and in the cloud for production, with infrastructure swapped as needed. You can mix components from different providers within a single blueprint; for example, combining AWS clusters with HashiCorp Vault for secrets, or pairing cloud infrastructure with self-hosted monitoring and logging. This systematic approach allows you to swap components to fit your environment requirements or vendor choices.

Blueprints function as shareable artifacts. You can package tested infrastructure patterns and distribute them through OCI registries. Your tested "web application with monitoring" blueprint becomes available across your organization. Someone else's "microservices with service mesh" blueprint becomes something you can install and adapt for your needs.

The Windsor Core library (`github.com/windsorcli/core`) provides tested components for common infrastructure needs. Terraform components create cloud resources like networks and clusters. Kustomize components deploy applications and services to Kubernetes. You can start building on top of a complete system using these off-the-shelf components without writing much custom infrastructure code.

== Blueprint Composition
#index("blueprints")
Blueprints work by organizing systems into two distinct layers that build on each other. The Terraform layer handles vendor API interactions to create resources like networks, clusters, and storage. The Kustomize layer describes Kubernetes state for services, monitoring, security policies, and workloads.

#figure(
  image("/diagrams/generated/blueprint-system-composition.png", width: 80%),
  caption: [Blueprint composition showing how Terraform and Kustomize components create system layers.]
)

Dependencies flow naturally between these layers. Vendor resources must exist before Kubernetes can use them. Within each layer, components also have dependencies. Networks must exist before clusters, and PKI must be established before ingress controllers. Blueprint files declare these relationships and organize them into a coherent deployment sequence.

This layered approach lets you swap Terraform components without changing Kubernetes configurations. A bare metal or on-premises blueprint might use `cluster/talos` while an AWS blueprint uses `cluster/aws-eks`. The same Kustomize components work with either choice because they describe Kubernetes state independently of how the cluster was created.

== Complete Blueprint Example
#index("blueprint example")
A complete blueprint demonstrates how components work together to create a functional environment. Here's a local development blueprint that includes essential vendor resources and cloud-native services:

```yaml
kind: Blueprint
apiVersion: blueprints.windsorcli.dev/v1alpha1
metadata:
  name: local-development
  description: Local development environment with essential services
repository:
  url: http://git.test/git/project
  ref:
    branch: main
  secretName: flux-system

# Vendor API Layer
terraform:
- path: cluster/talos          # Bare metal cluster foundation
- path: gitops/flux            # GitOps workflow management
  destroy: false

# Cloud-Native Services Layer
kustomize:
- name: pki-base               # Certificate infrastructure foundation
  path: pki/base
  components:
  - cert-manager
  - trust-manager

- name: pki-resources          # Certificate configuration
  path: pki/resources
  dependsOn: [pki-base]
  components:
  - private-issuer/ca
  - public-issuer/selfsigned

- name: csi                     # Storage management
  path: csi
  components:
  - openebs
  - openebs/dynamic-localpv
  cleanup: [pvcs]

- name: ingress                # HTTP routing
  path: ingress
  dependsOn: [pki-resources]
  components:
  - nginx
  - nginx/nodeport
  - nginx/coredns
  cleanup: [loadbalancers, ingresses]

- name: dns                    # DNS management
  path: dns
  components:
  - coredns
  - external-dns
  - external-dns/localhost
  - external-dns/coredns

- name: observability          # Monitoring and logging
  path: observability
  dependsOn: [csi, ingress]
  components:
  - grafana
  - grafana/ingress
  - grafana/prometheus
  - fluentd
  - fluentd/outputs/quickwit
  - quickwit
```

This blueprint creates a complete local development environment with certificate management, storage, HTTP routing, DNS resolution, and full observability. The same structure adapts to different environments by swapping components.

== Blueprint Structure
#index("blueprint structure")
Windsor blueprints use declarative YAML configuration to define system composition. Blueprint files specify Terraform and Kustomize components, their lifecycle management, deployment parallelism, and dependency relationships that implement the layered architecture shown in the diagram above.

=== Basic Blueprint Structure
Every Windsor blueprint follows a consistent structure with two main sections:

```yaml
kind: Blueprint
apiVersion: blueprints.windsorcli.dev/v1alpha1
metadata:
  name: example-system
  description: Example infrastructure system

# Vendor API layer
  terraform:
  - path: cluster/talos

# Cloud-native services layer
  kustomize:
  - name: ingress
    path: ingress
    components:
    - nginx
```

The `terraform` section creates vendor resources through cloud provider APIs, while the `kustomize` section configures self-hosted cloud-native services on Kubernetes. This separation enables the layered architecture where vendor resources support cloud-native services.

=== Component Dependencies
Blueprint dependencies reflect the inherent relationships between vendor APIs and cloud-native services. Vendor resources must be provisioned before the cloud-native and Kubernetes layer can be built on top. Within each layer, components have their own prerequisites—networks before clusters, PKI before ingress controllers, monitoring before applications.

Windsor processes these dependencies differently for each layer. Terraform components deploy sequentially with `dependsOn` managing variable chaining from component outputs to inputs. Terraform orders operations by building and walking a resource dependency graph, enabling safe parallelism where possible. Kustomize components can parallelize deployment where dependencies allow, respecting prerequisite relationships for proper initialization order.

== Component Patterns
#index("components")
Windsor components solve specific operational problems while maintaining consistent interfaces. The same blueprint structure works across different providers by swapping components. Declarative component inputs keep blueprint interfaces constrained and reviewable as the catalog grows.

=== Terraform Layer Components
Terraform components create the foundational resources that Kubernetes services depend on. Component selection reflects the operational context and platform targets.

*Local Development*
A typical local development setup uses `cluster/talos` to provision a minimal, secure Kubernetes cluster that runs efficiently on developer hardware. GitOps workflows are managed with `gitops/flux` for automated configuration.

```yaml
terraform:
- path: cluster/talos          # Bare metal/VM cluster
  parallelism: 1
- path: gitops/flux            # GitOps workflow
  destroy: false
```

The `parallelism: 1` setting ensures the cluster builds sequentially, which is important for node upgrades. The `destroy: false` on GitOps skips unnecessary cleanup when the underlying cluster is destroyed. This flag may also be used to protect certain resources during environment teardown.

*Cloud Providers*
Cloud blueprints often include managed Kubernetes services and supporting network modules. For example, AWS uses `cluster/aws-eks` with `network/aws-vpc`, while Azure uses `cluster/azure-aks` with `network/azure-vnet`. These modules provide integration with provider features such as auto-scaling, monitoring, and compliance.

```yaml
terraform:
- path: network/aws-vpc        # AWS networking
- path: cluster/aws-eks        # Managed Kubernetes
- path: cluster/aws-eks/additions  # Additional EKS features
  destroy: false
- path: gitops/flux            # GitOps workflow
  destroy: false
```

Notice how cloud environments include network components that local development doesn't need. Local development typically uses existing network infrastructure, while cloud environments require explicit network configuration for security and isolation.

=== Kubernetes Layer Components
Kubernetes components provide platform capabilities that run on top of the infrastructure. The examples below use Windsor Core components to illustrate how blueprints compose capabilities per environment, without enumerating every possible layer.

*Example: Certificate and Policy Foundation*
Every cluster needs certificate management and policy enforcement. In Core, this is a two-step pattern: install the foundation, then apply the environment-specific resources.

```yaml
# Certificate infrastructure
- name: pki-base
  path: pki/base
  components:
  - cert-manager
  - trust-manager

- name: pki-resources
  path: pki/resources
  dependsOn: [pki-base]
  components:
  - private-issuer/ca
  - public-issuer/selfsigned
```

Policy uses the same pattern to install the engine first, then load your policy set.

```yaml
# Policy
- name: policy-base
  path: policy/base
  components:
    - kyverno

- name: policy-resources
  path: policy/resources
  components:
    - kyverno/pod-security/baseline    # Pod Security Standards baseline profile
    - kyverno/best-practices/basic     # Resource limits, labels, probes
  dependsOn: [policy-base]
```

*Example: HTTP ingress variants*
Select ingress sub-components based on environment. Local environments typically use NodePort, while cloud environments use LoadBalancer.

```yaml
- name: ingress
  path: ingress
  dependsOn: [pki-resources]
  components:
  - nginx
  - nginx/loadbalancer    # Cloud or bare metal environments
  # or
  - nginx/nodeport        # Local development
```

*Example: DNS integration*
Combine internal DNS with an external provider automation sub-component.

```yaml
- name: dns
  path: dns
  components:
  - coredns               # Private DNS
  - external-dns          # Automation
  - external-dns/route53  # AWS
  # or
  - external-dns/coredns # Local / self-hosted DNS
```

*Example: Observability stacks*
Core separates telemetry collection from observability dashboards, allowing different combinations per environment.

```yaml
# Telemetry collection layer
- name: telemetry-base
  path: telemetry/base
  components:
  - prometheus
  - prometheus/flux
  - fluentbit
  - fluentbit/prometheus
- name: telemetry-resources
  path: telemetry/resources
  dependsOn: [telemetry-base]
  components:
  - metrics-server
  - prometheus
  - prometheus/flux
  - fluentbit
  - fluentbit/containerd
  - fluentbit/kubernetes
  - fluentbit/systemd

# On-prem observability (full stack)
- name: observability
  path: observability
  dependsOn: [csi, ingress]
  components:
  - fluentd
  - fluentd/filters/otel
  - fluentd/outputs/quickwit
  - quickwit
  - quickwit/pvc
  - grafana
  - grafana/ingress
  - grafana/prometheus
  - grafana/node
  - grafana/kubernetes
  - grafana/flux
  - grafana/quickwit
```

```yaml
# Production observability (external log aggregation)
- name: observability
  path: observability
  dependsOn: [ingress]
  components:
  - fluentd
  - fluentd/outputs/elasticsearch  # External ELK cluster
  - grafana
  - grafana/ingress
  - grafana/prometheus
  - grafana/kubernetes
```

=== Building Blueprint Variants
Blueprint variants solve the same functional requirements with different components.

*Core Blueprint Structure*
The Core library includes pre-built blueprints for common deployment targets: `aws`, `azure`, `metal`, and `local`. These blueprints solve identical functional requirements - they all provide clusters, storage, networking, DNS, observability, and security policies.

The differences are component selection. AWS blueprints use `network/aws-vpc` and integrate DNS with Route53. Metal blueprints skip network setup and run CoreDNS with etcd backends. Local blueprints include load balancer components that cloud blueprints omit.

*Component Selection Logic*
When building blueprints, you decide whether to run a service yourself or integrate with an external API. If your environment provides an API (cloud storage, managed DNS), you use integration components. If not, you include the service components.

This decision happens at the infrastructure layer. Kubernetes layer components remain identical - cert-manager, Kyverno policies, Prometheus, and Grafana deploy the same way regardless of whether they run on AWS or bare metal.

*Customization Points*
You customize blueprints by swapping components or adjusting sub-components. Replace observability components for different monitoring strategies. Add compliance policy components for regulatory requirements. Remove components you don't need.

Core blueprints provide working starting points. Most blueprint work involves customizing these rather than building from scratch.

== Understanding Windsor Components
#index("components")
A Windsor component is a directory containing infrastructure definitions and resource manifests for a specific system function. Components use standard Terraform and Kustomize formats while following organizational conventions that enable composition and compatibility with other components.

Consider the `terraform/cluster/aws-eks/` component. This directory contains standard Terraform files that create an EKS cluster with node groups, security policies, and cluster authentication. The component accepts variables like cluster name, Kubernetes version, and node specifications. It outputs cluster endpoints and authentication details for other components to reference.

```
terraform/cluster/aws-eks/
├── main.tf           # EKS cluster and node group resources
├── variables.tf      # Input validation and type definitions
├── outputs.tf        # Cluster connection details
└── README.md         # Component documentation
```

The equivalent `terraform/cluster/talos/` component creates Kubernetes clusters using Talos Linux. Both components accept similar inputs and produce compatible outputs. Blueprint files reference either component without modification, which enables environment portability.

Kustomize components configure cluster resources using Kubernetes APIs. The `kustomize/pki/base/` component deploys cert-manager and trust-manager to establish certificate infrastructure. The component includes Kubernetes manifests, Helm references, and configuration patches.

```
kustomize/pki/base/
├── kustomization.yaml     # Component composition
├── namespace.yaml         # Namespace definitions
├── cert-manager/          # Cert-manager subcomponent
└── trust-manager/         # Trust-manager subcomponent
```

Components solve specific operational problems. The `ingress/nginx` component handles HTTP routing and load balancing. The `dns/external-dns` component synchronizes Kubernetes services with cloud DNS providers. The `observability/grafana` component provides monitoring dashboards and alerting.

=== Component Boundaries

Components maintain clear functional boundaries. Terraform components provision vendor resources through third-party APIs like compute instances, networks, storage accounts, and managed databases. Kustomize components configure cluster resources through Kubernetes APIs like namespaces, services, ingress controllers, and monitoring stacks. Each component manages its own lifecycle and follows organizational conventions.

Component dependencies are explicit and managed at the blueprint level. A cluster component must complete before ingress components can deploy to it. PKI components must establish certificate authorities before ingress components can request certificates. This explicit dependency management allows components to deploy in parallel when possible while ensuring correct sequencing when required.

=== Component Portability

Components handle vendor-specific implementation details while maintaining consistent variable structures. Teams select AWS, Azure, or bare metal providers by choosing different components that accept similar inputs. Component internals handle vendor differences while blueprint files define the integrations between components.

Environment portability comes from component design and blueprint integration patterns. Self-hosted or edge environments might use the `cluster/talos` component with self-signed certificates, while cloud-based production uses `cluster/aws-eks` with enterprise PKI. The blueprint structure remains consistent across these different implementations.

This portability extends across the entire platform stack. Cloud-native applications require consistent service interfaces regardless of the underlying infrastructure. Teams building production systems need to understand how platform services map across different deployment environments. The table below illustrates core platform services and their typical implementations across different providers.

#figure(
  table(
    columns: 4,
    align: center,
    [*Service*], [*Self-Hosted*], [*AWS*], [*Azure*],
    [Networking], [VLAN/SDN], [AWS VPC], [Azure VNet],
    [Compute], [KubeVirt], [EC2], [VM],
    [Cluster], [Kubernetes], [EKS], [AKS],
    [Storage], [OpenEBS], [EBS], [Azure Disk],
    [Object Storage], [MinIO], [S3], [Azure Blob],
    [Load Balancing], [MetalLB], [ALB/NLB], [Azure LB],
    [DNS], [CoreDNS], [Route 53], [Azure DNS],
    [Database], [CloudNativePG], [RDS], [Azure Database],
    [Identity], [Keycloak], [Cognito], [Azure AD],
    [Monitoring], [Grafana], [CloudWatch], [Azure Monitor],
    [Secrets], [Vault], [Secrets Manager], [Key Vault],
  ),
  caption: [Platform service equivalency across deployment environments.]
)

When building on Kubernetes, teams can use self-hosted variants of core components across providers. Most popular databases run in high availability mode on Kubernetes. Kubernetes interfaces configure many provider-specific services directly. The AWS-EBS CSI driver runs natively on EKS, which configures persistent volumes on EBS under-the-hood, _etc._ The more you choose to build on Kubernetes, the more portability you can potentially achieve. Defining these configurations as a blueprint helps you begin organizing your infrastructure in a manner that helps actualize that portability.

== Terraform Component Conventions
#index("Terraform")
Terraform components in Windsor follow conventions that reduce configuration complexity. Folder structure separates functional categories from vendor implementations, making component discovery and relationship understanding straightforward.

=== Folder Structure
Windsor organizes Terraform components in a hierarchy:

```
terraform/
├── backend/          # State storage layer
│   ├── azurerm/      # Azure implementation
│   └── s3/           # AWS implementation
├── network/          # Network layer
│   ├── aws-vpc/      # AWS implementation
│   └── azure-vnet/   # Azure implementation
├── cluster/          # Cluster layer
│   ├── aws-eks/      # AWS implementation
│   ├── azure-aks/    # Azure implementation
│   └── talos/        # Bare metal/VM implementation
└── gitops/           # GitOps layer
    └── flux/         # Flux implementation
```

Each component contains the standard Terraform files: `main.tf`, `variables.tf`, `outputs.tf`, and `README.md`. This standardization keeps components small and focused. These files are also expected by the Windsor packing system when working with blueprint artifacts. Components within the same layer (like `cluster/aws-eks` and `cluster/talos`) accept similar variables, and meet some assumptions about the way the component interacts with other components, but create different infrastructure.

Windsor contexts organize environment-specific configuration in a parallel structure:

```
contexts/
├── local/              # Local development context
│   ├── blueprint.yaml  # Blueprint definition
│   ├── windsor.yaml    # Context configuration
│   ├── terraform/      # Variable files
│   │   ├── cluster/
│   │   │   └── talos.tfvars
│   │   └── gitops/
│   │       └── flux.tfvars
│   └── kustomize/      # Kustomize patches
├── staging/            # Staging environment
│   ├── blueprint.yaml
│   ├── windsor.yaml
│   ├── terraform/
│   │   ├── backend.tfvars  # Terraform remote state configuration
│   │   ├── backend/
│   │   │   └── s3.tfvars
│   │   ├── cluster/
│   │   │   └── aws-eks.tfvars
│   │   └── gitops/
│   │       └── flux.tfvars
│   └── kustomize/
└── production/           # Production environment
    ├── blueprint.yaml
    ├── windsor.yaml
    ├── terraform/
    │   ├── backend.tfvars
    │   ├── backend/
    │   │   └── s3.tfvars
    │   ├── cluster/
    │   │   └── aws-eks.tfvars
    │   └── gitops/
    │       └── flux.tfvars
    └── kustomize/
```

Each context contains its own blueprint definition and variable files that correspond to the components being used. The `terraform/` directory within each context mirrors the component structure, providing values for the variables that components define.

=== CLI Integration

Windsor CLI configures the Terraform environment. When working within component directories, Windsor sets environment variables that include relevant configuration files:

```bash
# Automatically configured via the Windsor CLI shell hook
cd terraform/cluster/talos
terraform init    # Uses backend config from context
terraform plan    # Uses variables from context
terraform apply   # Uses variables from context
```

This integration enables standard Terraform usage without additional flags. Windsor handles context-specific configuration transparently.

You can investigate how Windsor configures Terraform by examining the environment variables it sets. Within a Terraform component directory, run `windsor env | grep TF_` to see the underlying Terraform CLI configuration:

```bash
cd terraform/cluster/talos
windsor env | grep TF_

TF_CLI_ARGS_apply="/path/to/contexts/local/.terraform/cluster/talos/terraform.tfplan"
TF_CLI_ARGS_destroy=-var-file="/path/to/contexts/local/terraform/cluster/talos.tfvars"
TF_CLI_ARGS_init=-backend=true -force-copy -backend-config="path=/path/to/contexts/local/.tfstate/cluster/talos/terraform.tfstate"
TF_CLI_ARGS_plan=-out="/path/to/contexts/local/.terraform/cluster/talos/terraform.tfplan" -var-file="/path/to/contexts/local/terraform/cluster/talos.tfvars"
TF_CLI_ARGS_refresh=-var-file="/path/to/contexts/local/terraform/cluster/talos.tfvars"
TF_DATA_DIR=/path/to/contexts/local/.terraform/cluster/talos
TF_VAR_context_id=wv23pwkw
TF_VAR_context_path=/path/to/contexts/local
TF_VAR_os_type=unix
```

This output shows how Windsor configures Terraform commands with the appropriate variable files, state paths, and context information. The `TF_CLI_ARGS_*` variables prepend arguments to each Terraform subcommand, while `TF_VAR_*` variables provide context-specific values to Terraform modules.

Windsor provides several special variables to all Terraform components to enable consistent resource identification and context-aware behavior:

#table(
  columns: 2,
  [*Variable*], [*Purpose*],
  [*context_id*], [Static identifier for resource namespacing. Used for S3 bucket names, resource tags, and other identifiers that must be unique.],
  [*context_path*], [Path to the context directory. Enables modules to automatically generate credential files like kubeconfig or access configuration files.],
  [*os_type*], [Host operating system type (unix, windows). Used for edge cases requiring host-specific scripting or workarounds. Likely to be removed in the future.]
)

These variables are always available in Terraform components and provide consistent behavior across different contexts and environments. Blueprint designers can reference them in component configurations to ensure proper resource naming and context-aware functionality.

=== Component Dependencies and Output Chaining
#index("terraform dependencies")
Terraform components can declare dependencies on other components using the `dependsOn` field in blueprint definitions. When a component depends on another, Windsor extracts outputs from the dependent component and chains them as input variables to the dependent component using `TF_VAR_` prefixed environment variables.

This mechanism enables data flow between Terraform components:

```yaml
# Blueprint with component dependencies
terraform:
  - name: network
    path: network/aws-vpc
  - name: cluster
    path: cluster/aws-eks
    dependsOn:
      - network
```

When the `cluster` component runs, Windsor extracts outputs from the `network` component and chains them as environment variables:

```bash
# Windsor sets these variables for the cluster component
TF_VAR_vpc_id=vpc-12345678
TF_VAR_subnet_ids=subnet-12345678,subnet-87654321
TF_VAR_private_subnet_ids=subnet-abcdef12,subnet-fedcba21
```

The dependent component's Terraform modules receive these variables automatically, eliminating manual output/input coordination. This pattern enables deployments where infrastructure components build upon each other.

Output chaining follows Terraform's standard output format. The tool reads the state of dependent components and converts output values to environment variables.

== Kustomize Component Conventions
#index("Kustomize")
Kustomize components build on Kubernetes' native configuration management while incorporating Windsor's organizational patterns. They configure cluster resources, deploy platform services, and manage application workloads using Kubernetes APIs.

Kustomize components provide reusable, composable configuration units that can be referenced and modified independently. This component system enables the modular architecture used throughout the Windsor framework.

=== Component Structure

Kustomize components organize Kubernetes resources by functional category:

```
kustomize/
├── pki/                      # Certificate management
│   ├── base/                 # Foundation (cert-manager, trust-manager)
│   │   ├── cert-manager/
│   │   ├── kustomization.yaml
│   │   └── namespace.yaml
│   └── resources/            # Common implementations (issuers, certificates)
│       ├── kustomization.yaml
│       └── issuers/
│       └── certificates/
├── ingress/                  # Ingress controllers
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   └── nginx/               # NGINX with variants
│       ├── kustomization.yaml
│       ├── nodeport/        # NodePort variant
│       ├── loadbalancer/    # LoadBalancer variant
│       └── web/             # Web configuration
├── dns/                     # DNS services
│   ├── coredns/             # Internal DNS
│   └── external-dns/        # External DNS
│       └── cloudflare/      # Cloudflare DNS integration
├── observability/           # Monitoring and logging
│   ├── grafana/             # Dashboards
│   ├── elasticsearch/       # Log storage
│   ├── kibana/              # Log visualization
│   ├── kustomization.yaml
│   └── namespace.yaml
└── policy/                  # Security policies
    └── base/                # Policy engines (Kyverno)
        ├── kustomization.yaml
        └── namespace.yaml
```

*Base and Resources Pattern*: The base/resources pattern provides one way to separate infrastructure installation from configuration. Base components install CRDs, operators, and foundational software. Resources components configure specific implementations using those foundations. The `pki/base` component installs cert-manager, while `pki/resources` contains specific issuers and certificates.

*Namespace Pattern*: Each component includes its own namespace definition. System components in Windsor's core library use `system-` prefixed namespaces like `system-csi`, `system-ingress`, `system-telemetry`, and `system-pki`. This enables consistent pod security, network policy, and compliance rules while allowing internal implementations to be swapped out.

For example, the `system-telemetry` namespace uses privileged pod security for telemetry collection, while `system-observability` uses baseline security for dashboards and visualization. This approach is more rational than stuffing all software into one overly privileged namespace or creating separate namespaces for every vendor.

*Sub-Components*: Kustomize sub-components modify base component configurations. The `ingress` component includes sub-components like `nginx`, `nginx/loadbalancer`, and `nginx/web` that modify how NGINX integrates with the underlying infrastructure. Blueprints select these sub-components to customize integrations for specific environments.

Kustomize patches compose Kubernetes resources without templating. Strategic merge and JSON6902 patches can be inlined or file-based.

```yaml
# Blueprint with sub-components
kustomize:
  - name: ingress
    path: ingress
    components:
      - nginx                  # NGINX ingress controller
      - nginx/loadbalancer     # LoadBalancer service for NGINX
      - nginx/web              # Web-specific NGINX configuration
  - name: dns
    path: dns
    components:
      - external-dns           # ExternalDNS for DNS management
      - external-dns/cloudflare # Cloudflare DNS integration
  - name: observability
    path: observability
    components:
      - grafana                # Grafana monitoring dashboards
      - grafana/ha             # High availability for Grafana
```

These patterns are conventions that make compositional architecture feasible. Sub-components typically configure options and integrations for a component. For example, some services may have a special "high availability" or `ha` sub-component that configures the service for high availability. Sub-components are also where integrations between components are configured. For example, you may configure the Cloudflare DNS integration by enabling the `external-dns/cloudflare` sub-component.

=== Component Composition
#index("component composition")
Windsor blueprints organize work by separating component creation from component composition. Components encapsulate implementation and integration details while blueprints select and compose these components without managing internal details.

Components encode operational knowledge into reusable modules. A PKI component includes certificate manager deployment, trust distribution, and renewal automation. The component can optionally include a certificate authority and preconfigure issuers, private certificates, and other PKI elements. These options are set at the blueprint layer and handled within the component itself.

Blueprints compose systems by selecting compatible components. They specify ingress controllers, monitoring stacks, and storage backends appropriate for the target environment. This compositional approach enables teams to build complete infrastructure systems from tested, reusable components while maintaining the flexibility to adapt to different environments and requirements.

#figure(
  image("/chapters/chapter03/final_image.png", width: 60%),
)


