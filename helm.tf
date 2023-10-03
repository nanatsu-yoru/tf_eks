resource "helm_release" "ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "nginx-ingress"
  create_namespace = true

  values = ["${file("../../files/helm/ingress.yaml")}"]

  set {
    name  = "controller.metrics.enabled"
    value = var.ingress_metrics_enabled
  }

  set {
    name  = "controller.config.enable-opentracing"
    value = "false"
  }

  set {
    name  = "controller.service.external.enabled"
    value = "true"
  }

  depends_on = [
    module.eks_managed_node_group
  ]
}

resource "kubectl_manifest" "rules" {
  for_each  = fileset(path.module, "../../files/rules/crd_*.yaml")
  force_new = true

  yaml_body = file("${each.key}")

  depends_in = [
    module.eks_managed_node_group,
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "storageclass" {
  depends_on = [
    module.eks_managed_node_group,
    module.eks_managed_node_group_service
  ]
  force_new = true
  yaml_body = <<YAML
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name:ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
YAML
}

resource "kubectl_manifest" "monitoring-global-tls" {
  depends_on = [
    module.eks_managed_node_group,
    module.eks_managed_node_group_service,
    helm_release.vault-crd,
    helm_release.ingress,
    helm_release.prometheus
  ]
  force_new = true
  yaml_body = <<YAML
---
apiVersion: "koudingspawn.de/v1
kind:Vault
metadata:
  name:global-tls
  namespace: monitoring
spec: 
  path: devops/certs/${local.environment}/monitoring
  type: "KEYVALUEV2"
YAML
}

resource "kubectl_manifest" "ingress-global-tls" {
  depends_on = [
    module.eks_managed_node_group,
    module.eks_managed_node_group_service,
    helm_release.vault-crd,
    helm_release.ingress,
    helm_release.prometheus
  ]
  force_new = true
  yaml_body = <<YAML
---
apiVersion: "koudingspawn.de/v1"
kind: Vault
metadata:
  name: global-tls
  namespace: nginx-ingress
spec:
  path: certs/${local.environment}/ingress
  type: "KEYVALUEV2"
YAML
}

resource "kubectl_manifest" "rules_vault" {
  force_new = true
  for_each  = fileset(path.module, "../../files/modules/vault*.yaml")
  yaml_body = file("${each.key}")
  depends_on = [
    module.eks_managed_node_group,
    module.eks_managed_node_group_service,
    helm_release.vault-crd
  ]
}

resource "kubectl_manifest" "rules_autoscaler" {
  for_each  = fileset(path.module, "../../files/autoscaler/*.yaml")
  force_new = true
  yaml_body = file("${each.key}")
  depends_on = [
    module.eks_managed_node_group,
    local_file.ServiceAccount,
    local_file.Deployment,
    local_file.RoleBinding,
    local_file.role,
    local_file.ClusterRoleBinding,
    local_file.ClusterRole
  ]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "monitoring"
  create_namespace = true

  values = ["${file("../../files/helm/grafana.yaml")}"]

  set {
    name  = "ingress.hosts[0]"
    value = "${local.account}-grafana-${local.environment}.vikvochka.com"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "${local.account}-grafana-${local.environment}.vikvochka.com"
  }
  depends_on = [
    module.eks_managed_node_group,
    helm_release.ingress
  ]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring_tools"
  force_update     = true
  create_namespace = true

  values = ["${file("../../files/helm/prometheus*.yaml")}"]

  set {
    name  = "alerts.ingress.hosts[0]"
    value = "${local.account}-alerts-${local.environment}.vikvochka.com"
  }

  set {
    name  = "prometheus.ingress.hosts[0]"
    value = "${local.account}-prometheus-${local.environment}.vikvochka.com"
  }

  set {
    name  = "alerts.ingress.tls[0].hosts[0]"
    value = "${local.account}-alerts-${local.environment}.vikvochka.com"
  }

  set {
    name  = "prometheus.ingress.tls[0].hosts[0]"
    value = "${local.account}-prometheus-${local.environment}.vikvochka.com"
  }
}

resource "helm_release" "vault-crd" {
  name             = "vault-crd"
  repository       = "https://daspawnw.github.io/helm-charts"
  chart            = "vault-crd"
  namespace        = "vault-crd"
  create_namespace = true

  set {
    name  = "vaultCRD.vaultUrl"
    value = "https://vikvochka.com:9333/v1/"
  }

  set {
    name  = "vaultCRD.vaultAuth"
    value = "token"
  }
  set {
    name  = "vaultCRD.tag"
    value = "1.11.0"
  }

  set_sensitive {
    name  = "vaultCRD.vaultToken"
    value = var.vault_token
  }

  depends_on = [
    module.eks_managed_node_group
  ]
}