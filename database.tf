resource "aws_rds_cluster" "RDSWP" {
  cluster_identifier = var.clusteridentifier
  engine             = var.db_engine
  engine_version     = var.db_engine_version
  database_name      = var.DBName
  master_username    = var.DBUser
  master_password    = var.DBPassword
  vpc_security_group_ids    = [aws_security_group.allow_aurora_access.id]
  db_subnet_group_name      = aws_db_subnet_group.DBSubnetGroup.id
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = "aurora-final-snapshot"

  # serverlessv2_scaling_configuration {
  #   max_capacity = var.db_max_capacity
  #   min_capacity = var.db_min_capacity
  # }
  # tags = {
  #   Name = "auroracluster-Wordpressdb"
  # }
}

resource "aws_rds_cluster_instance" "clusterinstance" {
  count              = var.db_count
  identifier         = "clusterinstance-${count.index}"
  cluster_identifier = aws_rds_cluster.RDSWP.id
  instance_class     = var.db_instance_class
  engine             = var.db_engine
  availability_zone  = "${var.region}${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "auroracluster-db-instance${count.index + 1}"
  }
}