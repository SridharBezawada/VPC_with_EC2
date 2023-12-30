output "public_ip"{
    description = "public IP of ec2 instance"
    value = aws_instance.my_instance
}

output "private_ip"{
    description = "private IP of ec2 instance"
    value = aws_instance.my_instance
}