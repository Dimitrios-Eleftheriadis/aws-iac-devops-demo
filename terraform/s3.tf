data "aws_iam_policy_document" "topic" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:${var.project_name}-${var.region_label[terraform.workspace]}-app-${terraform.workspace}-sns-topic-send-email"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.upload_file_bucket.arn]
    }
  }
}

# upload_file_s3_arn

resource "aws_s3_bucket" "upload_file_bucket" {
    bucket = "${var.project_name}-${var.region_label[terraform.workspace]}-app-${terraform.workspace}-upload-file-s3"

}


resource "aws_s3_bucket_notification" "upload_file_bucket_notification" {
  bucket = aws_s3_bucket.upload_file_bucket.id

  topic {
    topic_arn = aws_sns_topic.send_email_topic.arn  # Replace with your SNS topic ARN
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sns_topic_subscription.send_email_topic_subscription]
}