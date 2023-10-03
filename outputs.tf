output "cluster_id" {
  description = "Cluster ID."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Control plane endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "SG IDs related to control plane."
  value       = module.eks.cluster_security_group_id
}

# output "kubectl_config" {
#     description = "Generated kubectl config."
#     value = module.eks.kubeconfig
# }

# output "config_map_aws_auth" {
#     description = "K8s auth configuration"
#     value = module.eks.config_map_aws_auth
# }

output "region" {
  description = "AWS region"
  value       = local.region
}

output "cluster_name" {
  description = "K8s cluster name"
  value       = local.cluster_name
}

# output "internal_lb" {
#     description = "DNS value of K8s internal load balancer"
#     value = data.kubernetes_service.ingress_nginx_internal.status[0].load_balancer[0].ingress[0].hostname
# }

# output "external_lb" {
#     description = "DNS value of K8s external load balancer"
#     value = data.kuberenetes_service.ingress_nginx_external.status == null ? "No External" : data.kubernetes_service.ingress_nginx_external.status[0].load_balancer[0].ingress[0].hostname
# }