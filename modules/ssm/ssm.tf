resource "aws_ssm_parameter" "go-svc_env" {
    name = "sandbox-go-svc-env"
    type = "String"
    value = var.go-svc_env
}