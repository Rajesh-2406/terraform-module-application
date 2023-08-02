resource "aws_iam_policy" "policy" {
  name        = "${var.component}-${var.env}-ssm-pm-policy"
  path        = "/"
  description = "${var.component}-${var.env}-ssm-pm-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : "arn:aws:ssm:us-east-1:600222537277:parameter/roboshop.dev.frontend.*"
      }
    ]
  })
}

 resource  "aws_iam_role"  "role"  {
  name = "${component}-${var.env}-ec2-role"

  assume_role_policy = "jsonencode"({
      version = "2012-10-17"
      statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Sid = ""
          principal = {
             service = "ec2.amazonaws.com"
          }
        },
      ]
  })
}
resource "aws_iam-instance_profile" "instance_profile"  {
        name  = "${var.component-${var.env}-ec2-role"
        role  = aws_iam_role.role.name
    }
resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
 resource "aws_instance" "web" {
      ami = data.aws_ami.example.id
      instance_type          = "t3.micro"
      vpc_security_group_ids = ["sg-00a06bc0fff373ab1"]
        iam_instance_profile  = ""

    tags = {
      name = "HelloWorld"
  }
}

 resource "aws_instance"  "instance"  {
        ami = data.aws_ami.ami.id
        instance_type = [aws_security_group.sg.id]
        iam_instance_profile  = aws_iam_instance_profile.instance_profile.name
  }
 resource "aws_route53_record"  "dns" {
        zone_id = "z055331734ICV430E01P7"
        name  = "${var.component}-dev"
        type  = "A"
        ttl   = 30
        records = [aws_instance.instance,private_ip]
     }

resource "null_resource"  "ansible" {
        depends_on  = [aws_instance.instance,aws_route53_record.dns]
        provosioner "remote-exec" {
           connection  {
             type =  "ssh"
             user  = "centos"
             password =  "DevOps321"
             host =  aws_instance.web.public_ip
            }
         inline =  {
            "Sudo labauto ansible",
            "ansible-pull -i  localhost, -u https://github.com/Rajesh-2406/roboshop-ansible.git main.yml -e env=${var.env} -e role_name = ${var.component}
         }
        }
       }