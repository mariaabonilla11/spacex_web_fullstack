resource "aws_dynamodb_table" "spacex_launches" {
  name           = "spacex_launches"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "spacex-launches"
    Environment = "production"
  }
}
