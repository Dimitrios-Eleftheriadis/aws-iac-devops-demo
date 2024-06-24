resource "aws_sns_topic" "send_email_topic" {
    name = "${var.project_name}-${var.region_label[terraform.workspace]}-app-${terraform.workspace}-sns-topic-send-email"
    policy = data.aws_iam_policy_document.topic.json

}

resource "aws_sns_topic_subscription" "send_email_topic_subscription" {
    for_each = toset(var.distribution_lists["tech"][terraform.workspace])

    topic_arn = aws_sns_topic.send_email_topic.arn
    protocol = "email"
    endpoint=  each.key

}

resource "aws_ssm_parameter" "send_email_topic" {
    type = "String"
    description = "The ssm parameter for the sns topic"
    name = "/${var.project_name}/${terraform.workspace}/email_topic_arn"
    value = aws_sns_topic.send_email_topic.arn
}