output "elb_dns_name" {
  value = "${aws_elb.tara_elb.dns_name}"
}