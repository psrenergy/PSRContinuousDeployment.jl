aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 747020361772.dkr.ecr.us-east-1.amazonaws.com
docker build -t 747020361772.dkr.ecr.us-east-1.amazonaws.com/julia-publish-linux:latest .
docker push 747020361772.dkr.ecr.us-east-1.amazonaws.com/julia-publish-linux:latest