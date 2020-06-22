output "network_name" {
  value       = module.network
  description = "The created network"
}

output "route_names" {
  value       = [for route in module.network_routes.routes : route.name]
  description = "The route names associated with this VPC"
}

output "routes" {
  value       = module.network_routes.routes
  description = "The created routes resources"
}

output "subnets_regions" {
  value       = [for network in module.network.subnets : network.region]
  description = "The region where the subnets will be created"
}

output "subnets_names" {
  value       = [for network in module.network.subnets : network.name]
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = [for network in module.network.subnets : network.ip_cidr_range]
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = [for network in module.network.subnets : network.self_link]
  description = "The self-links of subnets being created"
}

output "subnets_flow_logs" {
  value       = [for network in module.network.subnets : length(network.log_config) != 0 ? true : false]
  description = "Whether the subnets will have VPC flow logs enabled"
}

