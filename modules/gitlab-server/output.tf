
output "gitlab_server_ip" {
  value = aws_eip.gitlab_eip.public_ip
}

output "instance_id" {
  value = aws_instance.gitlab_server.id
}

output "instance_public_ip" {
  value = aws_eip.gitlab_eip.public_ip
}

output "public_ip" {
  value = aws_eip.gitlab_eip.public_ip
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "subnet_ids" {
  value = { for id in data.aws_subnets.default.ids : id => id }
}

output "gitlab_root_password" {
  value = data.local_file.gitlab_root_password.content
}

output "gitlab_access_token" {
  value = data.local_file.access_token.content
}

output "jenkins_root_password" {
  value = data.local_file.gitlab_root_password.content
}