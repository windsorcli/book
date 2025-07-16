#import "@preview/in-dexter:0.7.2": *

= Blueprint Fundamentals
#index("blueprints")
Modern infrastructure management coordinates configurations across multiple tools, platforms, and abstraction layers. Each tool has its own conventions, dependencies, and failure modes. Teams face a choice between vendor-specific tools for convenience or maintaining flexibility at the cost of operational complexity.

These tools mix configuration complexity with operational choices. Platform engineers write complex configuration code to expose simple operational decisions: AWS or Azure, PostgreSQL or MySQL, self-signed or enterprise certificates. This mixing forces specialized knowledge into every operational decision, creating bottlenecks where teams need platform engineering expertise to make basic deployment choices.

Windsor blueprints address this coordination problem by separating configuration from options. Platform engineers encode complex configuration logic once. Development teams select from exposed options without understanding the underlying implementation details. This chapter examines Windsor's layered architecture and how it reduces operational overhead while preserving deployment flexibility—not through vendor abstractions that obscure complexity, but through systematic composition that makes complexity manageable.

The Windsor Core library (`github.com/windsorcli/core`) supplies production-ready components for infrastructure and application deployment. IaC modules provision compute, networks, and clusters. Kustomize components manage security, ingress, and monitoring. Teams maintain flexibility while avoiding vendor lock-in.

== Blueprints as System Abstractions
#index("blueprints")
Windsor blueprints operate above individual IaC packages. Instead of managing separate IaC modules, Helm charts, and Kubernetes manifests, blueprints define complete systems as unified specifications.

A web application requires databases, load balancing, monitoring, and security policies. Conventional approaches require separate configurations for each component, with manual coordination between them. Windsor blueprints encode these relationships explicitly.

Blueprints separate system design from implementation specifics. Cloud providers offer different services, but blueprints describe systems functionally: what you need, not how vendors implement it. Windsor's templating system handles vendor differences through conditional logic.

Blueprints formalize the configuration/options boundary with a clean split: configuration consists of IaC files, Helm configs, and Kubernetes manifests that platform engineers write once; options are context values that development teams select for each deployment. Platform engineers handle integration complexity in code. Development teams make choices through simple variable assignments.

Vendor independence comes through functional equivalence. Cloud-native systems can mix and match services across multiple cloud providers when designed properly. A blueprint specifies PostgreSQL for data storage, Redis for caching, and Kubernetes for compute—these functional requirements work with AWS RDS and ElastiCache with EKS, Azure Database and Cache with AKS, or self-hosted alternatives on bare metal.

This approach provides these benefits:

*Complete System Definition*: Blueprints capture the entire dependency graph, ensuring all components integrate properly.

*Cross-Platform Deployment*: Blueprints adapt across AWS, Azure, or bare metal through templating and conditional logic.

*Single Source of Truth*: Change the blueprint once, deploy everywhere consistently.

*Environment Flexibility*: Use managed services in production, self-hosted alternatives in development.

== System Layers and Dependencies
#index("dependency management")
Cloud-native systems organize naturally into dependency layers—each tier depends on the foundation beneath it. Windsor blueprints formalize this architecture, establishing predictable deployment patterns that reduce the operational complexity of managing interdependent components.

#figure(
  image("/diagrams/generated/blueprint-abstract-layers.png", width: 40%),
  caption: [Layered System Architecture for Windsor blueprints.]
)

The diagram shows Windsor's layered approach. Dependencies flow upward: applications require services, services require platform capabilities, and all layers depend on infrastructure. This logical organization forms the foundation of Windsor's deployment predictability.

A monitoring dashboard deployment requires ingress controllers for accessibility, which require certificates for security, which require a cluster for execution. Component `dependsOn` declarations encode these relationships, ensuring components deploy in proper sequence automatically.

This layered approach provides four operational benefits:

*Predictable Deployments*: Windsor resolves the dependency graph and deploys components in correct sequence, preventing race conditions and deployment failures.

*Modular Architecture*: Swap implementations at any layer without affecting others. This proves valuable for applications requiring broad deployment compatibility—whether delivering to self-hosted customers, supporting on-premises deployments, or maintaining multi-cloud strategies.

*Environment Consistency*: Identical component configurations and relationships apply across environments. Development environments behave like production because they use identical component compositions.

*Clear Debugging*: When failures occur, the layer structure indicates exactly where to investigate. Platform issues remain distinct from application problems, and infrastructure failures don't masquerade as service outages.

== Understanding Windsor Components
#index("components")
Windsor unifies different tool concepts under a single "component" model. Terraform has modules, Kubernetes has manifests, and Helm has charts. Windsor treats them all as components—discrete units of functionality that can be composed together.

A Windsor component can combine HCL and Kubernetes manifests, all written in standard formats or JSON. This unified approach enables complete system definition within a single component when needed, rather than forcing artificial separation between infrastructure and application layers.

The `pki/base` component exemplifies this approach. It provides identical cert-manager foundations whether using self-signed certificates locally or enterprise PKI in production. The component definition remains constant—only the selected resources change per environment.

=== Component Structure

Windsor components follow consistent but flexible patterns:

*Declarative Configuration*: Standard files define component functionality. IaC tools use standard files like `main.tf`, `variables.tf`, `outputs.tf`. Kustomize uses `kustomization.yaml`.

*Environment Independence*: Component definitions function universally. Environment-specific configuration comes from external sources—variable files for IaC tools, component selection for Kustomize.

*Explicit Dependencies*: Components declare requirements clearly. IaC tools reference resources directly, Kustomize uses `dependsOn` in blueprints.

*Validated Interfaces*: IaC components validate inputs before deployment, catching configuration errors early.

=== Component Types
#index("IaC components")
#index("Kustomize components")
Windsor components follow specific patterns based on their implementation approach:

*IaC Components*: Handle infrastructure provisioning using the standard pattern of `main.tf`, `variables.tf`, and `outputs.tf` files. They reside in `terraform/` directories and are scoped to specific layers—compute, network, cluster, DNS, load balancers, storage. Each layer uses generic terms rather than vendor-specific names, with one component per vendor at each layer. The cluster layer includes `aws-eks/`, `azure-aks/`, and `talos/` components.

*Kustomize Components*: Use Kubernetes native component structure with sub-components representing integrations or high-level features. They reside in `kustomize/` directories and can include variants for different deployment scenarios. Sub-components function like options when implementing vendor Helm charts or Kubernetes manifests.

== IaC Component Conventions
#index("IaC")
IaC components in Windsor follow conventions that reduce configuration complexity. The folder structure separates functional categories from vendor implementations, making component discovery and relationship understanding straightforward.

=== Folder Structure
Windsor organizes IaC components hierarchically:

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

Each component contains the required `main.tf`, `variables.tf`, and `outputs.tf` files, plus `README.md`. This standardization ensures consistency within each layer while allowing vendor-specific implementations. Components stay small in scope with maximum overlap between sibling components in the same layer.

=== Variable Management
#index("variable management")
Windsor separates variable definitions from values, enabling identical components to function across environments. This separation demonstrates the configuration/options pattern cleanly: configuration lives in `main.tf`, `variables.tf`, and `outputs.tf` files that platform engineers write; options live in context variable files that development teams populate with their deployment choices.

Components define variables with validation—this is where platform engineers encode configuration complexity:

```hcl
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "node_groups" {
  description = "EKS node group configurations"
  type = list(object({
    name           = string
    instance_types = list(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
  validation {
    condition = alltrue([
      for ng in var.node_groups : ng.scaling_config.min_size <= ng.scaling_config.desired_size
    ])
    error_message = "Minimum size must not exceed desired size for node groups"
  }
}
```

Contexts provide values through `.tfvars` files—this is where development teams make choices:

```hcl
# contexts/local/terraform/cluster/talos.tfvars
cluster_name = "local-dev"
kubernetes_version = "1.33.1"
controlplanes = [{
  endpoint = "127.0.0.1:50000"
  node     = "controlplane-1"
}]

# contexts/production/terraform/cluster/eks.tfvars
cluster_name = "prod-workloads"
kubernetes_version = "1.33.0"
node_groups = [{
  name           = "general"
  instance_types = ["m5.large", "m5.xlarge"]
  scaling_config = {
    desired_size = 3
    max_size     = 10
    min_size     = 1
  }
}]
```

The same complex validation logic handles both local Talos clusters and production EKS clusters. Development teams select different options while the configuration complexity remains consistent. Windsor automatically includes appropriate variable files when executing IaC commands.

=== CLI Integration

Windsor CLI configures the IaC environment automatically. When working within component directories, Windsor sets environment variables that include relevant configuration files:

```bash
# Automatically configured by Windsor
cd terraform/cluster/talos
terraform init    # Uses backend config from context
terraform plan    # Uses variables from context
terraform apply   # Uses variables from context
```

This integration enables standard IaC tool usage without additional flags. Windsor handles context-specific configuration transparently.

== Kustomize Component Conventions
#index("Kustomize")
Kustomize components build on Kubernetes' native configuration management while incorporating Windsor's organizational patterns. They handle application deployment, configuration management, and integration with cluster infrastructure.

=== Component Structure

Kustomize components follow Kubernetes patterns with Windsor organization:

```
kustomize/
├── pki/              # Certificate management
│   ├── base/         # Foundation (cert-manager, trust-manager)
│   └── resources/    # Implementations (issuers, certificates)
├── ingress/          # Ingress controllers
│   ├── nginx/        # NGINX with variants
│   │   ├── nodeport/     # NodePort variant
│   │   ├── loadbalancer/ # LoadBalancer variant
│   │   └── web/          # Web configuration
├── dns/              # DNS services
│   ├── coredns/      # Internal DNS
│   └── external-dns/ # External DNS
├── observability/    # Monitoring and logging
│   ├── grafana/      # Dashboards
│   ├── elasticsearch/ # Log storage
│   └── kibana/       # Log visualization
└── policy/           # Security policies
    ├── base/         # Policy engines (Kyverno)
    └── resources/    # Concrete policies
```

*Base and Resources Pattern*: Windsor separates foundation from implementation. The `pki/base` component installs cert-manager, while `pki/resources` contains specific issuers and certificates. This allows identical foundations to support different security policies across environments.

*Sub-Components*: Windsor implements Kustomize components with sub-components that represent integrations or high-level features. The `ingress/nginx` component includes sub-components like `nodeport/`, `loadbalancer/`, and `web/` that function as options when deploying NGINX ingress controllers.

=== Component Composition
#index("component composition")
Blueprints compose Kustomize components through the `components` field, demonstrating the configuration/options separation at the application layer. Configuration consists of Kubernetes manifests and Helm charts that platform engineers write; options are the component selections that development teams make in blueprint files.

The configuration complexity lives in component definitions:

```yaml
# kustomize/pki/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - cert-manager-namespace.yaml
  - cert-manager-crds.yaml
  - cert-manager-deployment.yaml
  - trust-manager-deployment.yaml

components:
  - cert-manager
  - trust-manager
```

Development teams select options through blueprint composition:

```yaml
# Local development options
kustomize:
  - name: pki-base
    path: pki/base
    components:
      - cert-manager
      - trust-manager
  - name: pki-resources
    path: pki/resources
    dependsOn:
      - pki-base
    components:
      - private-issuer/ca
      - public-issuer/selfsigned
  - name: ingress
    path: ingress
    components:
      - nginx
      - nginx/nodeport

# Production options
kustomize:
  - name: pki-base
    path: pki/base
    components:
      - cert-manager
      - trust-manager
  - name: pki-resources
    path: pki/resources
    dependsOn:
      - pki-base
    components:
      - private-issuer/vault
      - public-issuer/letsencrypt
  - name: ingress
    path: ingress
    components:
      - nginx
      - nginx/loadbalancer
      - nginx/web
```

The same `pki/base` component works in both environments, but development teams select different certificate issuers and ingress variants. Different environments can include different components—local environments include `demo/bookinfo` for testing, while production includes comprehensive observability components.

Dependencies ensure correct deployment order. The `pki-resources` component depends on `pki-base`, ensuring certificates are available before applications attempt to use them.

== Blueprint Configuration
#index("blueprint configuration")
Windsor blueprints use declarative YAML configuration to define system composition. The blueprint file describes which components to include, how they should be configured, and the dependencies between them.

=== Blueprint Structure
A typical blueprint contains sections for IaC and Kustomize components:

```yaml
apiVersion: windsor.io/v1alpha1
kind: Blueprint
metadata:
  name: example-system
spec:
  terraform:
    - name: backend
      path: terraform/backend/s3
    - name: network
      path: terraform/network/aws-vpc
    - name: cluster
      path: terraform/cluster/aws-eks
      dependsOn:
        - network
  kustomize:
    - name: pki-base
      path: kustomize/pki/base
    - name: pki-resources
      path: kustomize/pki/resources
      dependsOn:
        - pki-base
    - name: ingress
      path: kustomize/ingress
      components:
        - nginx
        - nginx/loadbalancer
```

The `dependsOn` field ensures components deploy in correct order. Windsor resolves the dependency graph and deploys components accordingly.

=== Environment Adaptation
#index("environment adaptation")
Blueprints adapt to different environments through context-specific configuration, demonstrating the configuration/options separation at scale. Platform engineers create blueprints that encode complex system architectures. Development teams deploy them across environments by selecting appropriate contexts and components.

Identical blueprints function across development, staging, and production by changing the context:

```bash
# Deploy to local environment (Talos, self-signed certs, NodePort)
windsor up --install

# Deploy to production (EKS, Vault PKI, LoadBalancer)
windsor context use production
windsor up --install
```

The same blueprint deploys different implementations based on context selection. Development teams make deployment choices without understanding the underlying configuration complexities. This separation enables platform engineers to focus on encoding best practices while development teams focus on selecting appropriate options.
