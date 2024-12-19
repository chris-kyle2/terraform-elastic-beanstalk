output "RDSEndpoint" {
  value = aws_db_instance.vprofile-rds.endpoint
}

output "MemcacheEndpoint" {
  value = aws_elasticache_cluster.vprofile-elasticCache-cluster.configuration_endpoint

}

output "RabbitMQEndpoint" {
    value = aws_mq_broker.vprofile-rmq.instances[0].endpoints
  
}