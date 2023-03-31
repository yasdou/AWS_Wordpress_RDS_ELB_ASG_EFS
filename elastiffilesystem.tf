//elasticfilesystem.tf

# Creating Amazon EFS File system
resource "aws_efs_file_system" "WPfilesystem" {
# Creating the AWS EFS lifecycle policy
# Amazon EFS supports two lifecycle policies. Transition into IA and Transition out of IA
# Transition into IA transition files into the file systems's Infrequent Access storage class
# Transition files out of IA storage
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "WPfilesystem"
  }
}

# Creating the EFS access point for AWS EFS File system
resource "aws_efs_access_point" "WPEFSaccesspoint" {
  file_system_id = aws_efs_file_system.WPfilesystem.id
}
# Creating the AWS EFS System policy to transition files into and out of the file system.
resource "aws_efs_file_system_policy" "WPEFSpolicy" {
  file_system_id = aws_efs_file_system.WPfilesystem.id
# The EFS System Policy allows clients to mount, read and perform 
# write operations on File system 
# The communication of client and EFS is set using aws:secureTransport Option
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy01",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.WPfilesystem.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}
# Creating the AWS EFS Mount point in a specified Subnet 
# AWS EFS Mount point uses File system ID to launch.
resource "aws_efs_mount_target" "WPEFSmount" {
  file_system_id = aws_efs_file_system.WPfilesystem.id
  subnet_id      = aws_subnet.private_subnet_1.id
}