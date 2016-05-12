{
  "Version": "2008-10-17",
  "Id": "Policy123456789101112",
  "Statement": [
    {
      "Sid": "Stmt123456789101112",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::test-nginx-1-bucket/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "${server_1_public_ip}/32"
          ]
        }
      }
    }
  ]
}