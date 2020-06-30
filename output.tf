# output "alb_url" {
#     value = module.ecs.alb_url
# }

# output "alb_url" {
#     value = module.hello-world.alb_url
# }

output "ecs-role" {
    value = module.ecs.ecs-role
}

output "elb-url" {
    value = module.ecs.alb_url
}