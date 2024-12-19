resource "aws_launch_template" "vprofile" {
  name = "vprofile-launch-template"

  iam_instance_profile {
    name = "aws-elasticbeanstalk-ec2-role" # Ensure this role exists
  }

  image_id      = "ami-0e2c8caa4b6378d8c" # Replace with your desired AMI ID
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.vprofile-prod-sg.id]
    subnet_id                   = module.vpc.private_subnets[0]
  }

  key_name = aws_key_pair.vprofilekey.key_name

  tags = {
    Name = "vprofile-template"
  }
}
