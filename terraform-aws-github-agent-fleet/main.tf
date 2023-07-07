locals{

	module_name="L1 Module - GithubRunner - LaunchTemplates"
	owner="terraform-aws-L1-launch-templates"
	email="platform_team@okera.com"
	
}

provider "aws" {
   region  = "us-west-2"
   default_tags {
      tags = module.default_tags.all_tags
   }
}

module "default_tags"  {

  source 			= "git::https://github.com/okeraplatform/terraform-aws-L1-modules//terraform-aws-tags"
  
  project_name	    =var.project
  environment	    =var.env 
  module_name	    =local.module_name 
  owner			    =local.owner
  email			    =local.email

}

resource "aws_launch_template" "goldenLaunchTemplate" {
  name_prefix   = "launch-template-${var.name}"
  image_id      = var.ec2_ami
  instance_type = var.instance_type
  user_data = filebase64(var.user_data_script) 	
  key_name = var.keyfile_name

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }
  network_interfaces {
      subnet_id              = data.aws_subnets.okera_subnets.ids[0]
	  security_groups =[data.aws_security_groups.okera_security_group.ids[0]]
  }

}

resource "aws_autoscaling_group" "asgGithub" {
  name  = "ec2-${var.name}-asg"
  vpc_zone_identifier =  [data.aws_subnets.okera_subnets.ids[0]]
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.desired_capacity
  capacity_rebalance = true
  protect_from_scale_in = false

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.goldenLaunchTemplate.id
        version            = "$Latest"
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "ec2-${var.name}-fleet"
    propagate_at_launch = true
 }
 
}