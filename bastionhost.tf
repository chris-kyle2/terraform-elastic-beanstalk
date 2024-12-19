data "aws_ami" "ubuntu22AMI" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}




resource "aws_instance" "bastion-instance" {
  ami                    = data.aws_ami.ubuntu22AMI.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vprofilekey.key_name
  count                  = var.instance_count
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.vprofile-bastion-sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "Bastion-host"
    Project = "beanstalk java app using terraform"
  }
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }

  provisioner "file" {
    content     = templatefile("templates/db-deploy.tmpl", { rds-endpoint = aws_db_instance.vprofile-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/vprofile-dbdeploy.sh"
    
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vprofile-dbdeploy.sh",
      "sudo /tmp/vprofile-dbdeploy.sh"
    ]
  }
}